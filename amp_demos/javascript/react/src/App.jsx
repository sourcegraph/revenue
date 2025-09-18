import React from 'react'

function App() {
  return (
    <div className="container">
      <header>
        <h1>React Demo Application</h1>
      </header>
      
      <main className="content">
        <div style={{textAlign: 'center', padding: '2rem 0'}}>
          <h2>Welcome to the React Demo Application!</h2>
          
          <p style={{fontSize: '1.2em', marginBottom: '2rem', color: '#666'}}>
            This is a demonstration application built with React and Vite.
          </p>
          
          <div style={{
            display: 'flex', 
            flexWrap: 'wrap', 
            gap: '2rem', 
            justifyContent: 'center', 
            marginTop: '3rem'
          }}>
            <div style={{
              background: '#f8f9fa', 
              padding: '1.5rem', 
              borderRadius: '8px', 
              boxShadow: '0 2px 4px rgba(0,0,0,0.1)', 
              maxWidth: '300px'
            }}>
              <h3 style={{color: '#4a5568', marginTop: 0}}>⚛️ React Framework</h3>
              <p>Built with React for creating interactive user interfaces with components.</p>
            </div>
            
            <div style={{
              background: '#f8f9fa', 
              padding: '1.5rem', 
              borderRadius: '8px', 
              boxShadow: '0 2px 4px rgba(0,0,0,0.1)', 
              maxWidth: '300px'
            }}>
              <h3 style={{color: '#4a5568', marginTop: 0}}>⚡ Vite Bundler</h3>
              <p>Using Vite for fast development and optimized production builds.</p>
            </div>
          </div>
   
          <div style={{marginTop: '3rem'}}>
            <h3>Getting Started</h3>
            <p>This application demonstrates a React setup equivalent to the Ktor server-side application.</p>
            <p>Explore the codebase to see how components, styling, and bundling work together.</p>
          </div>
        </div>
      </main>
      
      <footer>
        <p>&copy; 2025 Sourcegraph Revenue Team</p>
      </footer>
    </div>
  )
}

export default App
