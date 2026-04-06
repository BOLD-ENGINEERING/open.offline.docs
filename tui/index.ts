import { createCliRenderer, Box, Text } from "@opentui/core"
import { execSync } from "child_process"
import { readFileSync, existsSync } from "fs"
import { resolve, dirname } from "path"
import { fileURLToPath } from "url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

function loadEnvBaseDir(): string {
  const envPath = resolve(__dirname, "..", ".env")
  if (existsSync(envPath)) {
    const content = readFileSync(envPath, "utf-8")
    const match = content.match(/^BASE_DIR=(.+)$/m)
    if (match) return match[1].trim()
  }
  return resolve(__dirname, "..")
}

const BASE_DIR = loadEnvBaseDir()

interface MenuItem {
  label: string
  description: string
  action: () => Promise<void> | void
  section: string
}

const renderer = await createCliRenderer({
  exitOnCtrlC: true,
})

let selectedIndex = 0
let message = ""
let messageColor = "#00FF00"
let messageTimer: ReturnType<typeof setTimeout> | null = null
let terminalWidth = process.stdout.columns || 80
let terminalHeight = process.stdout.rows || 24

function showMessage(msg: string, color = "#00FF00") {
  message = msg
  messageColor = color
  if (messageTimer) clearTimeout(messageTimer)
  messageTimer = setTimeout(() => {
    message = ""
    render()
  }, 4000)
}

function runCommand(cmd: string): string {
  try {
    return execSync(cmd, { cwd: BASE_DIR, encoding: "utf-8", timeout: 30000 })
  } catch (e: any) {
    return e.stdout?.toString() || e.message || "Command failed"
  }
}

async function buildImages() {
  showMessage("Building Docker images...", "#FFFF00")
  render()
  const output = runCommand("bash ood build")
  showMessage("Build complete", "#00FF00")
  render()
}

async function startServices() {
  showMessage("Starting services...", "#FFFF00")
  render()
  const output = runCommand("bash ood up")
  showMessage("Services started", "#00FF00")
  render()
}

async function stopServices() {
  showMessage("Stopping services...", "#FFFF00")
  render()
  const output = runCommand("bash ood down")
  showMessage("Services stopped", "#00FF00")
  render()
}

async function checkStatus() {
  showMessage("Checking status...", "#FFFF00")
  render()
  const output = runCommand("bash ood status")
  showMessage("Status retrieved", "#00FF00")
  render()
}

async function runDoctor() {
  showMessage("Running diagnostics...", "#FFFF00")
  render()
  const output = runCommand("bash ood doctor")
  showMessage("Diagnostics complete", "#00FF00")
  render()
}

async function cleanUp() {
  showMessage("Cleaning up...", "#FFFF00")
  render()
  const output = runCommand("bash ood clean")
  showMessage("Cleanup complete", "#00FF00")
  render()
}

const menuItems: MenuItem[] = [
  { label: "Doctor", description: "Check system dependencies", action: runDoctor, section: "System" },
  { label: "Build", description: "Build Docker images", action: buildImages, section: "System" },
  { label: "Up", description: "Start all services", action: startServices, section: "Services" },
  { label: "Down", description: "Stop all services", action: stopServices, section: "Services" },
  { label: "Status", description: "Show container status", action: checkStatus, section: "Services" },
  { label: "Clean", description: "Clean up containers and images", action: cleanUp, section: "Services" },
  { label: "List Docs", description: "List available documentation", action: () => showMessage("See docs below", "#00FF00"), section: "Docs" },
]

let currentSection = ""

function render() {
  renderer.root.remove("app")

  const children: any[] = []

  // Title bar
  children.push(
    Text({
      content: " Open Offline Docs - Manager ",
      fg: "#000000",
      bg: "#00FFFF",
    }),
  )
  children.push(Text({ content: "" }))

  // Menu items
  for (let i = 0; i < menuItems.length; i++) {
    const item = menuItems[i]
    const isSelected = i === selectedIndex

    if (item.section !== currentSection) {
      currentSection = item.section
      if (i > 0) children.push(Text({ content: "" }))
      children.push(Text({ content: ` ${currentSection}`, fg: "#00FFFF" }))
    }

    const prefix = isSelected ? " > " : "   "
    const fg = isSelected ? "#00FFFF" : "#FFFFFF"
    children.push(
      Text({
        content: `${prefix}${item.label}`,
        fg,
      }),
    )
    children.push(
      Text({
        content: `    ${item.description}`,
        fg: "#666666",
      }),
    )
  }

  // Message
  if (message) {
    children.push(Text({ content: "" }))
    children.push(Text({ content: `  ${message}`, fg: messageColor }))
  }

  // Footer
  children.push(Text({ content: "" }))
  children.push(Text({ content: " ──────────────────────────────────────", fg: "#333333" }))
  children.push(Text({ content: " ↑/↓ Navigate  Enter Execute  q Quit", fg: "#888888" }))

  renderer.root.add(
    Box(
      {
        id: "app",
        borderStyle: "rounded",
        padding: 1,
        flexDirection: "column",
        gap: 0,
      },
      ...children,
    ),
  )
}

renderer.keyInput.on("keypress", (key: any) => {
  switch (key.name) {
    case "up":
      if (selectedIndex > 0) {
        selectedIndex--
        render()
      }
      break
    case "down":
      if (selectedIndex < menuItems.length - 1) {
        selectedIndex++
        render()
      }
      break
    case "return":
    case "enter":
      menuItems[selectedIndex].action()
      break
    case "q":
      renderer.destroy()
      process.exit(0)
      break
  }
})

render()
