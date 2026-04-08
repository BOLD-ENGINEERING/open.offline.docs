#!/usr/bin/env python3
"""
Open Offline Docs - Manager Service

CLI tool for managing documentation containers via docker-py.
Outputs structured JSON for all operations.

Usage:
    python manager.py list
    python manager.py start <name> <port>
    python manager.py stop <name>
    python manager.py status <name>

Environment:
    OOD_DOCS_PATH: Path to docs directory (default: <repo>/docs)
"""

import argparse
import json
import os
import sys
from typing import Any, Optional

import docker
from docker.errors import NotFound, APIError # type: ignore

CONTAINER_PREFIX = "ood-doc-"
DEFAULT_DOCS_PATH = os.environ.get("OOD_DOCS_PATH", os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs"))

DOC_CONFIGS = {
    "fastapi": {
        "path": "fastapi.docs",
        "type": "mkdocs",
        "default_port": 8000,
    },
    "astro": {
        "path": "astro.docs",
        "type": "astro",
        "default_port": 8001,
    },
    "alpine": {
        "path": "alpine.docs",
        "type": "mkdocs",
        "default_port": 8002,
    },
    "php": {
        "path": "php.docs",
        "type": "static",
        "default_port": 8003,
    },
    "python": {
        "path": "python.docs",
        "type": "static",
        "default_port": 8004,
    },
    "slimphp": {
        "path": "slim.php.docs",
        "type": "jekyll",
        "default_port": 8005,
    },
}


def get_docker_client():
    """Get Docker client with error handling."""
    try:
        return docker.from_env()
    except docker.errors.DockerException as e: # type: ignore
        json_error(f"Docker is not available: {str(e)}")


client = get_docker_client()


def json_output(data: dict) -> None:
    """Print JSON output and exit."""
    print(json.dumps(data))
    sys.exit(0)


def json_error(message: str, code: int = 1) -> None:
    """Print JSON error and exit."""
    print(json.dumps({"error": message}))
    sys.exit(code)


def get_container_name(name: str) -> str:
    """Get the full container name with prefix."""
    return f"{CONTAINER_PREFIX}{name}"


def get_container(name: str):
    """Get a container by name. Returns None if not found."""
    global client
    container_name = get_container_name(name)
    try:
        return client.containers.get(container_name) # type: ignore
    except NotFound:
        return None
    except APIError as e:
        raise Exception(f"Docker API error: {str(e)}")
    except Exception as e:
        # Re-initialize client if it was None
        if client is None:
            client = get_docker_client()
            if client is None:
                raise Exception("Docker client unavailable")
        return client.containers.get(container_name)


def cmd_list(args: Any) -> None:
    """List all running doc containers."""
    try:
        all_containers = client.containers.list(all=True) # type: ignore
        running_docs = []

        for container in all_containers:
            if container.name.startswith(CONTAINER_PREFIX):
                doc_name = container.name[len(CONTAINER_PREFIX):]
                config = DOC_CONFIGS.get(doc_name, {})
                
                ports = container.ports or {}
                host_port = None
                for container_port, host_bindings in ports.items():
                    if host_bindings:
                        host_port = host_bindings[0]["HostPort"]
                        break

                running_docs.append({
                    "name": container.name,
                    "doc_name": doc_name,
                    "status": container.status,
                    "port": host_port,
                    "type": config.get("type", "unknown"),
                    "id": container.id[:12],
                })

        json_output(running_docs) # type: ignore
    except APIError as e:
        json_error(f"Failed to list containers: {str(e)}")
    except Exception as e:
        json_error(f"Unexpected error: {str(e)}")


def cmd_start(args: Any) -> None:
    """Start a doc container."""
    name = args.name
    port = args.port

    if name not in DOC_CONFIGS:
        json_error(f"Unknown doc: {name}. Available: {', '.join(DOC_CONFIGS.keys())}")

    config = DOC_CONFIGS[name]
    container_name = get_container_name(name)
    docs_path = DEFAULT_DOCS_PATH

    existing = get_container(name)
    if existing:
        if existing.status == "running":
            ports = existing.ports or {}
            host_port = None
            for container_port, host_bindings in ports.items():
                if host_bindings:
                    host_port = host_bindings[0]["HostPort"]
                    break
            
            json_output({
                "status": "already_running",
                "name": container_name,
                "port": host_port,
                "id": existing.id[:12], # type: ignore
            })
            return
        else:
            try:
                existing.start()
                json_output({
                    "status": "started",
                    "name": container_name,
                    "port": port,
                    "id": existing.id[:12], # type: ignore
                })
                return
            except APIError as e:
                json_error(f"Failed to start container: {str(e)}")

    doc_type = config["type"]
    doc_path = f"{docs_path}/{config['path']}"
    
    volumes = {}
    working_dir = "/app"
    
    env = {
        "DOC_TYPE": doc_type,
        "PORT": str(port),
        "DOC_PATH": working_dir,
    }
    
    if doc_type == "mkdocs":
        cmd = f"python3 -m mkdocs serve --dev-addr 0.0.0.0:{port}"
        volumes = {doc_path: {"bind": working_dir, "mode": "ro"}}
    elif doc_type == "astro":
        volumes = {doc_path: {"bind": working_dir, "mode": "ro"}}
        working_dir = f"{working_dir}/.."
    elif doc_type == "jekyll":
        cmd = f"bundle exec jekyll serve --host 0.0.0.0 --port {port}"
        volumes = {doc_path: {"bind": working_dir, "mode": "ro"}}
    elif doc_type == "static":
        cmd = f"python3 -m http.server {port}"
        volumes = {doc_path: {"bind": working_dir, "mode": "ro"}}
    else:
        json_error(f"Unknown doc type: {doc_type}")

    image = "ood-doc-base:latest"

    try:
        container = client.containers.run( # type: ignore
            image,
            cmd, # type: ignore
            name=container_name,
            ports={"80/tcp": port, f"{port}/tcp": port},
            volumes=volumes,
            working_dir=working_dir,
            environment=env,
            detach=True,
            remove=False,
        )

        json_output({
            "status": "started",
            "name": container_name,
            "port": port,
            "id": container.id[:12], # type: ignore
        })
    except APIError as e:
        json_error(f"Failed to start container: {str(e)}")
    except Exception as e:
        json_error(f"Unexpected error: {str(e)}")


def cmd_stop(args: Any) -> None:
    """Stop a doc container."""
    name = args.name
    container_name = get_container_name(name)

    container = get_container(name)
    if not container:
        json_output({
            "status": "not_found",
            "name": container_name,
        })
        return

    try:
        if container.status == "running":
            container.stop(timeout=10)
        
        container.remove(force=True)
        
        json_output({
            "status": "stopped",
            "name": container_name,
        })
    except APIError as e:
        json_error(f"Failed to stop container: {str(e)}")
    except Exception as e:
        json_error(f"Unexpected error: {str(e)}")


def cmd_status(args: Any) -> None:
    """Get status of a doc container."""
    name = args.name
    container_name = get_container_name(name)

    container = get_container(name)
    if not container:
        json_output({
            "name": container_name,
            "doc_name": name,
            "status": "not_found",
            "port": None,
            "id": None,
        })
        return

    ports = container.ports or {}
    host_port = None
    for container_port, host_bindings in ports.items():
        if host_bindings:
            host_port = host_bindings[0]["HostPort"]
            break

    config = DOC_CONFIGS.get(name, {})

    json_output({
        "name": container.name,
        "doc_name": name,
        "status": container.status,
        "port": host_port,
        "type": config.get("type", "unknown"),
        "id": container.id[:12], # type: ignore
    })


def main():
    parser = argparse.ArgumentParser(
        description="Open Offline Docs - Container Manager"
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    list_parser = subparsers.add_parser("list", help="List all doc containers")

    start_parser = subparsers.add_parser("start", help="Start a doc container")
    start_parser.add_argument("name", help="Name of the doc to start")
    start_parser.add_argument("port", type=int, help="Port to bind to")

    stop_parser = subparsers.add_parser("stop", help="Stop a doc container")
    stop_parser.add_argument("name", help="Name of the doc to stop")

    status_parser = subparsers.add_parser("status", help="Get container status")
    status_parser.add_argument("name", help="Name of the doc")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        json_error("No command specified")

    if args.command == "list":
        cmd_list(args)
    elif args.command == "start":
        cmd_start(args)
    elif args.command == "stop":
        cmd_stop(args)
    elif args.command == "status":
        cmd_status(args)
    else:
        json_error(f"Unknown command: {args.command}")


if __name__ == "__main__":
    main()
