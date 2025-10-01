import React, { Component } from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'

import './assets/scss/app.scss'

import Header from './components/Header'
import Footer from './components/Footer'
import Home from './components/pages/Home'
import Search from './components/pages/Search'
import Searches from './components/pages/Searches'
import Repos from './components/pages/Repos'
import About from './components/pages/About'
import Examples from './components/pages/Examples'
import NotFound from './components/pages/NotFound'

class App extends Component {
  render() {
    return (
      <Router>
        <div className="app grid-y medium-grid-frame">
          <Header />

          <section className="content cell medium-auto medium-cell-block-container">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/searches" element={<Searches />} />
              <Route path="/search/new" element={<Home />} />
              <Route path="/search/:id" element={<Search />} />
              <Route path="/repos" element={<Repos />} />
              <Route path="/about" element={<About />} />
              <Route path="/examples" element={<Examples />} />
              <Route path="*" element={<NotFound />} />
            </Routes>
          </section>

          <Footer />
        </div>
      </Router>
    )
  }
}

export default App;