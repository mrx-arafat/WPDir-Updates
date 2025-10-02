import React, { Component } from 'react'
import { format } from 'timeago.js'
import Config from '../utils/Config.js'
import DreamHostLink from './general/DreamHostLink.js'
import API from '../utils/API.js'

class Footer extends Component {
  constructor(props) {
    super(props)
    this.state = {
      lastUpdated: null,
      isLoading: true
    }
  }

  componentDidMount() {
    API.get('/repos/overview')
      .then(result => {
        // Get the most recent update time between plugins and themes
        const pluginsUpdated = result.data.plugins && result.data.plugins.updated
        const themesUpdated = result.data.themes && result.data.themes.updated

        let lastUpdated = null
        if (pluginsUpdated && themesUpdated) {
          const pluginsDate = Date.parse(pluginsUpdated)
          const themesDate = Date.parse(themesUpdated)
          // Only use if both dates are valid
          if (!isNaN(pluginsDate) && !isNaN(themesDate)) {
            lastUpdated = pluginsDate > themesDate ? pluginsUpdated : themesUpdated
          }
        } else if (pluginsUpdated) {
          const pluginsDate = Date.parse(pluginsUpdated)
          if (!isNaN(pluginsDate)) {
            lastUpdated = pluginsUpdated
          }
        } else if (themesUpdated) {
          const themesDate = Date.parse(themesUpdated)
          if (!isNaN(themesDate)) {
            lastUpdated = themesUpdated
          }
        }

        this.setState({
          lastUpdated: lastUpdated,
          isLoading: false
        })
      })
      .catch(error => {
        console.error('Failed to fetch last updated time:', error)
        this.setState({
          isLoading: false
        })
      })
  }

  render() {
    const { lastUpdated, isLoading } = this.state

    // Safely format the date
    let formattedDate = null
    if (lastUpdated) {
      const parsedDate = Date.parse(lastUpdated)
      if (!isNaN(parsedDate)) {
        try {
          formattedDate = format(parsedDate)
        } catch (e) {
          console.error('Error formatting date:', e)
        }
      }
    }

    return (
      <footer className="footer cell shrink">
        <div className="info">
          <span>Made with Love, Go and React by <a href="https://www.peterbooker.com" target="_blank" rel="noopener noreferrer">Peter Booker</a></span>&nbsp;-&nbsp;
          <span>Powered by <DreamHostLink height="16" width="120" /></span>&nbsp;-&nbsp;
          <span><a href="https://github.com/wpdirectory/wpdir" target="_blank" rel="noopener noreferrer" title={'Version: v' + Config.Version + ' Commit: ' + Config.Commit + ' Date: ' + Config.Date}>wpdir { Config.Version }</a></span>
          {!isLoading && formattedDate && (
            <>
              &nbsp;-&nbsp;
              <span title={lastUpdated}>Last Updated: {formattedDate}</span>
            </>
          )}
        </div>
      </footer>
    )
  }
}

export default Footer