import React from 'react'
import './common.css'

function App() {
  return (
    <div className="sg-container">
      <header className="sg-header">
        <h1>React Demo Application</h1>
      </header>
      
      <main className="sg-content">
        <section className="sg-welcome">
          <h2>Welcome to the React Demo Application!</h2>
          
          <p className="sg-muted">
            This is a demonstration application built with React and Vite.
          </p>
          
          <div className="sg-features">
            <article className="sg-card">
              <h3>⚛️ React Framework</h3>
              <p>Built with React for creating interactive user interfaces with components.</p>
            </article>
            
            <article className="sg-card">
              <h3>⚡ Vite Bundler</h3>
              <p>Using Vite for fast development and optimized production builds.</p>
            </article>
          </div>
   
          <section className="sg-center" style={{marginTop: 'var(--sg-space-12)'}}>
            <h3>Getting Started</h3>
            <p>This application demonstrates a React setup equivalent to the Ktor server-side application.</p>
            <p>Explore the codebase to see how components, styling, and bundling work together.</p>
          </section>
        </section>
      </main>
      
      <footer className="sg-footer">
        <p>&copy; 2025 Sourcegraph Revenue Team</p>
      </footer>
    </div>
  )
}

export default App
