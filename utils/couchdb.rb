require_relative './network'
require_relative './date'

# API wrapper for CouchDB
class CouchDB
  BASE_URL = "http://61.167.60.58:5984/secreek-event-dump/_design/secreek-event-dump/_view"
  SCORE_BOARD_URL = "#{BASE_URL}/status"
  HISTORY_URL = "#{BASE_URL}/history"
  BADGE_PLACEHOLDER_URL = "http://static.freepik.com/free-photo/vintage-badge_871062.jpg"

  # Get score board of all time
  def self.score_board
    NetworkUtils.do_request_returning_json SCORE_BOARD_URL
  end

  def self.activity_history
    NetworkUtils.do_request_returning_json HISTORY_URL
  end
end
