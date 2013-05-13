require_relative './network'
require_relative './date'

# API wrapper for CouchDB
class CouchDB
  SCORE_BOARD_URL = "http://61.167.60.58:5984/secreek-event-dump/_design/secreek-event-dump/_view/status"

  # Get score board of all time
  def self.score_board
    NetworkUtils.do_request_returning_json SCORE_BOARD_URL
  end
end
