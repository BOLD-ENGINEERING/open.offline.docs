<?php

declare(strict_types=1);

namespace App;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class DocsController
{
    private const DOCS_CONFIG = [
        'fastapi' => [
            'name' => 'FastAPI',
            'path' => 'fastapi.docs',
            'type' => 'mkdocs',
            'default_port' => 8000,
            'enabled' => true,
        ],
        'astro' => [
            'name' => 'Astro',
            'path' => 'astro.docs',
            'type' => 'astro',
            'default_port' => 8001,
            'enabled' => true,
        ],
        'alpine' => [
            'name' => 'Alpine.js',
            'path' => 'alpine.docs',
            'type' => 'mkdocs',
            'default_port' => 8002,
            'enabled' => true,
        ],
        'php' => [
            'name' => 'PHP',
            'path' => 'php.docs',
            'type' => 'static',
            'default_port' => 8003,
            'enabled' => true,
        ],
        'python' => [
            'name' => 'Python',
            'path' => 'python.docs',
            'type' => 'static',
            'default_port' => 8004,
            'enabled' => true,
        ],
        'slimphp' => [
            'name' => 'SlimPHP',
            'path' => 'slim.php.docs',
            'type' => 'jekyll',
            'default_port' => 8005,
            'enabled' => true,
        ],
    ];

    private function callManager(array $args): array
    {
        $managerPath = dirname(__DIR__, 2) . '/manager/manager.py';

        $cmd = array_merge(['python3', $managerPath], $args);
        $cmdStr = implode(' ', $cmd);

        $descriptorSpec = [
            0 => ['pipe', 'r'],
            1 => ['pipe', 'w'],
            2 => ['pipe', 'w'],
        ];

        $process = proc_open($cmdStr, $descriptorSpec, $pipes);

        if (!is_resource($process)) {
            return ['error' => 'Failed to execute manager'];
        }

        fclose($pipes[0]);

        $stdout = stream_get_contents($pipes[1]);
        $stderr = stream_get_contents($pipes[2]);

        proc_close($process);

        if ($stderr) {
            error_log("Manager error: {$stderr}");
        }

        $decoded = json_decode($stdout, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return ['error' => 'Invalid JSON from manager', 'raw' => $stdout];
        }

        return $decoded ?? ['error' => 'Empty response from manager'];
    }

    private function jsonSuccess(Response $response, $data, int $status = 200): Response
    {
        $response->getBody()->write(json_encode($data));
        return $response
            ->withStatus($status)
            ->withHeader('Content-Type', 'application/json');
    }

    private function jsonError(Response $response, string $message, int $status = 500): Response
    {
        return $this->jsonSuccess($response, ['error' => $message], $status);
    }

    public function list(Request $request, Response $response): Response
    {
        $result = $this->callManager(['list']);

        if (isset($result['error'])) {
            return $this->jsonError($response, $result['error'], 500);
        }

        $runningDocs = is_array($result) ? $result : [];

        $runningMap = [];
        foreach ($runningDocs as $doc) {
            $runningMap[$doc['doc_name'] ?? $doc['name']] = $doc;
        }

        $docs = [];
        foreach (self::DOCS_CONFIG as $key => $config) {
            $running = $runningMap[$key] ?? null;
            $docs[] = [
                'key' => $key,
                'name' => $config['name'],
                'type' => $config['type'],
                'enabled' => $config['enabled'],
                'default_port' => $config['default_port'],
                'status' => $running ? $running['status'] : 'stopped',
                'port' => $running['port'] ?? null,
            ];
        }

        return $this->jsonSuccess($response, $docs);
    }

    public function start(Request $request, Response $response, array $args): Response
    {
        $name = $args['name'] ?? null;

        if (!$name) {
            return $this->jsonError($response, 'Doc name is required', 400);
        }

        if (!isset(self::DOCS_CONFIG[$name])) {
            return $this->jsonError($response, "Unknown doc: {$name}", 404);
        }

        $config = self::DOCS_CONFIG[$name];
        $port = $config['default_port'];

        $result = $this->callManager(['start', $name, (string)$port]);

        if (isset($result['error'])) {
            return $this->jsonError($response, $result['error'], 500);
        }

        return $this->jsonSuccess($response, $result);
    }

    public function stop(Request $request, Response $response, array $args): Response
    {
        $name = $args['name'] ?? null;

        if (!$name) {
            return $this->jsonError($response, 'Doc name is required', 400);
        }

        $result = $this->callManager(['stop', $name]);

        if (isset($result['error'])) {
            return $this->jsonError($response, $result['error'], 500);
        }

        return $this->jsonSuccess($response, $result);
    }

    public function status(Request $request, Response $response, array $args): Response
    {
        $name = $args['name'] ?? null;

        if (!$name) {
            return $this->jsonError($response, 'Doc name is required', 400);
        }

        $result = $this->callManager(['status', $name]);

        if (isset($result['error'])) {
            return $this->jsonError($response, $result['error'], 500);
        }

        return $this->jsonSuccess($response, $result);
    }
}
