import { AuthProvider, queryClient } from '@spree/dashboard-core'
import { ConfirmProvider, ThemeProvider, TooltipProvider } from '@spree/dashboard-ui'
import { QueryClientProvider } from '@tanstack/react-query'
import { type AnyRouter, RouterProvider } from '@tanstack/react-router'
import { StrictMode } from 'react'

export function App({ router }: { router: AnyRouter }) {
  return (
    <StrictMode>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider>
          <TooltipProvider>
            <ConfirmProvider>
              <AuthProvider>
                <RouterProvider router={router} />
              </AuthProvider>
            </ConfirmProvider>
          </TooltipProvider>
        </ThemeProvider>
      </QueryClientProvider>
    </StrictMode>
  )
}
