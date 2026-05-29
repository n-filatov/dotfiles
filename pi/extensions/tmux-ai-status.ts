import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const script = join(homedir(), ".tmux", "plugins", "tmux-ai-status", "scripts", "set_state.sh");
const resetScript = join(homedir(), ".tmux", "plugins", "tmux-ai-status", "scripts", "reset.sh");

type State = "idle" | "thinking" | "working" | "needs_approval" | "error";

function inTmux(): boolean {
  return Boolean(process.env.TMUX && process.env.TMUX_PANE);
}

function setState(state: State): void {
  if (!inTmux()) return;
  if (!existsSync(script)) return;

  execFile(script, [state], { timeout: 3000 }, () => {
    // Best effort only. Never interrupt Pi because tmux status failed.
  });
}

function reset(): void {
  if (!inTmux()) return;
  if (!existsSync(resetScript)) {
    setState("idle");
    return;
  }

  execFile(resetScript, [], { timeout: 3000 }, () => {
    // Best effort only.
  });
}

export default function (pi: ExtensionAPI) {
  let activeTools = 0;
  let enabled = true;
  let sawToolError = false;

  const update = (state: State) => {
    if (!enabled) return;
    setState(state);
  };

  pi.on("session_start", async () => {
    activeTools = 0;
    sawToolError = false;
    update("idle");
  });

  pi.on("before_agent_start", async () => {
    activeTools = 0;
    sawToolError = false;
    update("thinking");
  });

  pi.on("agent_start", async () => {
    update("thinking");
  });

  pi.on("tool_execution_start", async () => {
    activeTools += 1;
    update("working");
  });

  pi.on("tool_execution_end", async (event) => {
    activeTools = Math.max(0, activeTools - 1);
    if (event.isError) sawToolError = true;

    if (activeTools > 0) {
      update("working");
    } else if (sawToolError) {
      update("error");
    } else {
      update("thinking");
    }
  });

  pi.on("agent_end", async () => {
    activeTools = 0;
    sawToolError = false;
    update("idle");
  });

  pi.on("session_shutdown", async () => {
    activeTools = 0;
    sawToolError = false;
    update("idle");
  });

  pi.registerCommand("tmux-ai-status", {
    description: "Control tmux-ai-status integration: on, off, idle, thinking, working, error, reset, test",
    handler: async (args, ctx) => {
      const command = args.trim() || "status";

      switch (command) {
        case "on":
          enabled = true;
          update("idle");
          ctx.ui.notify("tmux-ai-status enabled", "info");
          break;
        case "off":
          enabled = false;
          setState("idle");
          ctx.ui.notify("tmux-ai-status disabled", "info");
          break;
        case "idle":
        case "thinking":
        case "working":
        case "needs_approval":
        case "error":
          update(command as State);
          ctx.ui.notify(`tmux-ai-status set to ${command}`, "info");
          break;
        case "reset":
          reset();
          ctx.ui.notify("tmux-ai-status reset requested", "info");
          break;
        case "test":
          update("working");
          setTimeout(() => update("idle"), 1500);
          ctx.ui.notify("tmux-ai-status test: working for 1.5s", "info");
          break;
        case "status":
          ctx.ui.notify(
            `tmux-ai-status: ${enabled ? "enabled" : "disabled"}, tmux: ${inTmux() ? "yes" : "no"}, script: ${existsSync(script) ? "yes" : "missing"}`,
            "info",
          );
          break;
        default:
          ctx.ui.notify("Usage: /tmux-ai-status [status|on|off|idle|thinking|working|needs_approval|error|reset|test]", "warning");
      }
    },
  });
}
