import { type ChildProcess, spawn, spawnSync } from 'node:child_process'
import { existsSync } from 'node:fs'
import { resolve } from 'node:path'
import { spreeDashboardPlugin } from '@spree/dashboard/vite'
import react from '@vitejs/plugin-react'
import { defineConfig, loadEnv, type Plugin } from 'vite'

// `spree dev` only starts this app's dev server, so this server starts the POS
// dev server (apps/pos, http://localhost:5175) next to it and stops it on
// exit. POS stays its own app with its own origin, the same shape as a
// pos.example.com deploy. Set SPREE_POS_DEV=0 to skip it.
function posDevServer(): Plugin {
  const posDir = resolve(import.meta.dirname, '../pos')
  let child: ChildProcess | null = null

  const stop = () => {
    if (!child?.pid || child.exitCode !== null) return
    if (process.platform === 'win32') {
      // The shell wrapper does not forward signals; kill the whole tree.
      spawnSync('taskkill', ['/pid', String(child.pid), '/T', '/F'], { stdio: 'ignore' })
    } else {
      try {
        process.kill(-child.pid, 'SIGTERM')
      } catch {
        child.kill('SIGTERM')
      }
    }
    child = null
  }

  return {
    name: 'parkviet:pos-dev-server',
    apply: 'serve',
    configureServer(server) {
      if (process.env.SPREE_POS_DEV === '0' || process.env.VITEST) return
      if (!existsSync(resolve(posDir, 'node_modules'))) {
        server.config.logger.warn(
          'pos | apps/pos has no node_modules — run `pnpm install` there to start it with the dashboard.',
        )
        return
      }
      const proc = spawn('pnpm run dev', {
        cwd: posDir,
        stdio: ['ignore', 'pipe', 'pipe'],
        detached: process.platform !== 'win32',
        shell: true,
      })
      child = proc
      // `spree dev` takes the first "Local: http://…" line (colours stripped)
      // as the dashboard URL, so the POS line is relabelled to keep it from
      // matching. Vite colours the word, hence the optional escape codes.
      const localLabel = new RegExp(`Local((?:${String.fromCharCode(27)}\\[[0-9;]*m)*):`)
      const forward = (stream: NodeJS.ReadableStream | null, out: NodeJS.WriteStream) => {
        let buffer = ''
        stream?.on('data', (chunk) => {
          buffer += chunk.toString()
          const lines = buffer.split('\n')
          buffer = lines.pop() ?? ''
          for (const line of lines) out.write(`pos | ${line.replace(localLabel, 'POS$1:')}\n`)
        })
      }
      forward(proc.stdout, process.stdout)
      forward(proc.stderr, process.stderr)
      proc.on('exit', (code) => {
        // stop() clears `child` first, so a deliberate stop stays quiet.
        if (child !== proc) return
        child = null
        // 130 and 143 are Ctrl+C / SIGTERM reaching the POS process directly.
        if (code && code !== 130 && code !== 143) {
          server.config.logger.warn(
            `pos | POS dev server exited (code ${code}); run \`pnpm dev\` in apps/pos to see why.`,
          )
        }
      })
      server.httpServer?.on('close', stop)
      process.once('exit', stop)
      for (const signal of ['SIGINT', 'SIGTERM'] as const) {
        process.once(signal, () => {
          stop()
          process.exit()
        })
      }
    },
  }
}

export default defineConfig(({ mode }) => {
  // loadEnv, not process.env: Vite doesn't load .env files before evaluating
  // this config, and .env.local is where `spree` writes the proxy target.
  const env = loadEnv(mode, process.cwd(), 'VITE_')
  const proxyTarget = env.VITE_API_PROXY_TARGET || 'http://localhost:3000'

  return {
    // Sub-path mounting for the single-node topology (Rails serves the build
    // at /dashboard): build with VITE_BASE_PATH=/dashboard/ so asset URLs
    // resolve. Unset (dev, CDN root deploys) Vite defaults to '/'.
    base: process.env.VITE_BASE_PATH,
    // spreeDashboardPlugin bundles Tailwind, injects @source directives for
    // every Spree dashboard package, auto-discovers installed dashboard
    // plugins (package.json deps carrying the `spree.dashboard.plugin`
    // marker), serves the `virtual:spree-dashboard-plugins` module that
    // src/main.tsx imports to activate them, and composes the shell's and
    // every plugin's file routes into src/routeTree.gen.ts on each dev
    // start/build — commit that file; its diff shows what an upgrade added.
    plugins: [spreeDashboardPlugin(), react(), posDevServer()],
    // Proxy /api to the Rails server so the SPA is same-origin with the API
    // in dev — keeps the refresh-token cookie working under SameSite=Lax
    // without HTTPS. /rails covers Active Storage's presigned URLs. Proxy
    // target, not VITE_SPREE_API_URL — that switches the SDK to absolute
    // cross-origin URLs and bypasses this proxy (see .env.example).
    server: {
      // Reachable from a phone on the same network (`vite --host`) or through
      // a tunnel: Vite otherwise rejects any request whose Host header it does
      // not recognise. Dev server only — this file is not used for builds.
      allowedHosts: ['.localhost', '.trycloudflare.com', '.ngrok-free.app'],
      proxy: {
        // `secure: false`: the worktree's Rails URL is served by portless
        // behind a self-signed certificate, which Node refuses by default —
        // the proxy fails with "self-signed certificate in certificate
        // chain". Scoped to these two dev-only proxy routes rather than
        // disabling TLS verification for the whole process.
        '/api': { target: proxyTarget, changeOrigin: true, secure: false },
        '/rails': { target: proxyTarget, changeOrigin: true, secure: false },
      },
    },
  }
})
