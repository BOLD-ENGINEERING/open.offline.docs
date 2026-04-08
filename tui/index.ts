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

const ASCII_ART = [
  " _______/\\\\\\____________/\\\\\\_______/\\\\\\\\\\\\\\\\____          ",
  "  _____/\\\\\\///\\\\\\________/\\\\\\///\\\\\\____\\/\\\\\\////////\\\\\\__         ",
  "   ___/\\\\\\/__\\///\\\\\\____/\\\\\\/__\\///\\\\\\__\\/\\\\\\______\\//\\\\\\_        ",
  "    __/\\\\\\______\\//\\\\__/\\\\\\______\\//\\\\\\_\\/\\\\\\_______\\/\\\\\\_       ",
  "     _\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\_______\\/\\\\\\_      ",
  "      _\\//\\\\\\______/\\\\\\__\\//\\\\\\______/\\\\\\__\\/\\\\\\_______\\/\\\\\\_     ",
  "       __\\///\\\\\\__/\\\\\\_____\\///\\\\\\__/\\\\\\____\\/\\\\\\_______/\\\\\\__    ",
  "        ____\\///\\\\\\\\\\/_________\\///\\\\\\\\\\/_____\\/\\\\\\\\\\\\\\\\\\\\/___   ",
  "         ______\\/////____________\\/////_______\\////////////_____  ",
]

function loadAsciiArt(): string[] {
  const artPath = resolve(__dirname, "..", "banner.txt")
  if (existsSync(artPath)) {
    const content = readFileSync(artPath, "utf-8")
    return content
      .split("\n")
      .map((line) => line.replace(/\{\}/g, "").replace(/^\s+|\s+$/g, ""))
      .filter((line) => line.length > 0)
  }
  return ASCII_ART
}

const BASE_DIR = loadEnvBaseDir()
const TITLE_ART = loadAsciiArt()

interface MenuItem {
  key: string
  label: string
  description: string
  action: () => Promise<void> | void
  section: string
}

const renderer = await createCliRenderer({
  exitOnCtrlC: true,
})

let selectedIndex = 0
let outputLines: string[] = ["", "  Select a command and press Enter to execute"]
let isRunning = false
let mode = "NORMAL"

function runCommand(cmd: string): string {
  try {
    return execSync(cmd, { cwd: BASE_DIR, encoding: "utf-8", timeout: 60000 })
  } catch (e: any) {
    return e.stdout?.toString() || e.message || "Command failed"
  }
}

function formatOutput(raw: string): string[] {
  if (!raw) return ["  (no output)"]
  return raw.split("\n").map((line) => `  ${line}`)
}

async function executeAction(item: MenuItem) {
  if (isRunning) return
  isRunning = true
  mode = "RUNNING"
  outputLines = [`  Running: ${item.label}...`, ""]
  render()

  const result = item.action()
  if (result instanceof Promise) {
    await result
  }

  isRunning = false
  mode = "NORMAL"
  render()
}

const menuItems: MenuItem[] = [
  { key: "", label: "doctor", description: "Check system dependencies", action: () => { outputLines = formatOutput(runCommand("bash ood doctor")) }, section: "SYSTEM" },
  { key: "", label: "build", description: "Build Docker images (doc-base + api)", action: () => { outputLines = formatOutput(runCommand("bash ood build")) }, section: "SYSTEM" },
  { key: "", label: "up", description: "Start all services", action: () => { outputLines = formatOutput(runCommand("bash ood up")) }, section: "SERVICES" },
  { key: "", label: "up --only api", description: "Start only the API service", action: () => { outputLines = formatOutput(runCommand("bash ood up --only api")) }, section: "SERVICES" },
  { key: "", label: "down", description: "Stop all services", action: () => { outputLines = formatOutput(runCommand("bash ood down")) }, section: "SERVICES" },
  { key: "", label: "stop", description: "Stop all containers (alias for down)", action: () => { outputLines = formatOutput(runCommand("bash ood stop")) }, section: "SERVICES" },
  { key: "", label: "status", description: "Show container status", action: () => { outputLines = formatOutput(runCommand("bash ood status")) }, section: "SERVICES" },
  { key: "", label: "clean", description: "Stop + prune all containers", action: () => { outputLines = formatOutput(runCommand("bash ood clean")) }, section: "SERVICES" },
  { key: "", label: "list", description: "List available documentation sites", action: () => { outputLines = formatOutput(runCommand("bash ood list")) }, section: "DOCS" },
  { key: "", label: "help", description: "Show commands, options, and examples", action: () => { outputLines = formatOutput(runCommand("bash ood help")) }, section: "INFO" },
]

let currentSection = ""

function render() {
  renderer.root.remove("app")

  const width = process.stdout.columns || 80
  const height = process.stdout.rows || 24
  const leftWidth = Math.floor(width * 0.35)
  const statusBar = ` ${mode}  │  j/k: navigate  │  Enter: run  │  q: quit  │  ${menuItems.length} commands`

  // Header
  const header = [
    Text({ content: "  Open Offline Docs — Manager", fg: "#AAAAAA" }),
    Text({ content: "─".repeat(width - 4), fg: "#333333" }),
  ]

  // Left panel: menu
  const leftPanel: any[] = []
  currentSection = ""

  for (let i = 0; i < menuItems.length; i++) {
    const item = menuItems[i]
    const isSelected = i === selectedIndex

    if (item.section !== currentSection) {
      currentSection = item.section
      if (i > 0) leftPanel.push(Text({ content: "" }))
      leftPanel.push(Text({ content: `  ${item.section}`, fg: "#00DFFF" }))
    }

    const key = isSelected ? "▸" : " "
    const fg = isSelected ? "#00DFFF" : "#CCCCCC"
    const bg = isSelected ? "#1A1A2E" : undefined
    leftPanel.push(
      Text({
        content: `  ${key}  ${item.label}`,
        fg,
        bg,
      }),
    )
    leftPanel.push(
      Text({
        content: `     ${item.description}`,
        fg: "#555555",
        bg,
      }),
    )
  }

  // Right panel: output or ascii art welcome
  const rightPanel: any[] = [
    Text({ content: "  OUTPUT", fg: "#00DFFF" }),
    Text({ content: "─".repeat(Math.max(10, width - leftWidth - 10)), fg: "#333333" }),
  ]

  const isDefault = outputLines.length === 2 && outputLines[1].includes("Select a command")

  if (isDefault) {
    const artOffset = Math.max(0, Math.floor((width - leftWidth - 66) / 2))
    for (const line of TITLE_ART) {
      rightPanel.push(Text({ content: " ".repeat(artOffset) + line, fg: "#00DFFF" }))
    }
    rightPanel.push(Text({ content: "" }))
    rightPanel.push(Text({ content: "  Select a command and press Enter", fg: "#555555" }))
  } else {
    const visibleLines = outputLines.slice(-(height - 8))
    for (const line of visibleLines) {
      const isStatus = line.includes("Running:")
      rightPanel.push(
        Text({
          content: line,
          fg: isStatus ? "#FFFF00" : "#DDDDDD",
        }),
      )
    }
  }

  // Status bar
  const statusBarText = Text({
    content: statusBar.padEnd(width - 4),
    fg: "#000000",
    bg: "#00DFFF",
  })

  renderer.root.add(
    Box(
      {
        id: "app",
        flexDirection: "column",
        flexGrow: 1,
        height: "100%",
      },
      Box(
        {
          flexDirection: "column",
          flexGrow: 1,
          paddingX: 1,
          paddingY: 0,
        },
        ...header,
        Box(
          {
            flexDirection: "row",
            flexGrow: 1,
            gap: 0,
          },
          Box(
            {
              flexDirection: "column",
              width: leftWidth,
              paddingY: 0,
              borderStyle: "single",
              borderColor: "#333333",
            },
            ...leftPanel,
          ),
          Box(
            {
              flexDirection: "column",
              flexGrow: 1,
              paddingY: 0,
              paddingLeft: 1,
              borderStyle: "single",
              borderColor: "#333333",
            },
            ...rightPanel,
          ),
        ),
        Text({ content: "─".repeat(width - 4), fg: "#333333" }),
        statusBarText,
      ),
    ),
  )
}

renderer.keyInput.on("keypress", (key: any) => {
  if (isRunning) return

  switch (key.name) {
    case "j":
    case "down":
      if (selectedIndex < menuItems.length - 1) {
        selectedIndex++
        render()
      }
      break
    case "k":
    case "up":
      if (selectedIndex > 0) {
        selectedIndex--
        render()
      }
      break
    case "return":
    case "enter":
      executeAction(menuItems[selectedIndex])
      break
    case "q":
    case "escape":
      renderer.destroy()
      process.exit(0)
      break
  }
})

render()
