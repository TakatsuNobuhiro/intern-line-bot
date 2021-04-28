require "google/apis/calendar_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "date"
require "fileutils"
class CalendarController < ApplicationController
    OOB_URI = ENV["OOB_URI"].freeze
    APPLICATION_NAME = ENV["APPLICATION_NAME"].freeze
    
    # The file token.yaml stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    TOKEN_PATH = "token.yaml".freeze
    SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
    
    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials

    def index 
    end 

    def authorize
        client_id = ENV["CLIENT_ID"]
        
        token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
        authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
        
        user_id = ENV["MAIL"]
        credentials = authorizer.get_credentials user_id
        
        if credentials.nil?
            url = authorizer.get_authorization_url base_url: OOB_URI
            puts "Open the following URL in the browser and enter the " \
                "resulting code after authorization:\n" + url
            code = ENV["CODE"]
            
            credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: OOB_URI
            )
            
            
            
        end
        credentials
    end
    def callback
        #urlのcodeをsessionに格納

        session[:code] = params[:code]
        #念の為値をターミナルに吐き出す
        logger.debug(session[:code])
        calendar = Google::Apis::CalendarV3::CalendarService.new
        calendar.client_options.application_name = APPLICATION_NAME
        
        calendar.authorization = authorize
    
        redirect_to action: :index
    end


end