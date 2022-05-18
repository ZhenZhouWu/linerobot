require 'line/bot'
class SmallfoxController < ApplicationController
	protect_from_forgery with: :null_session


	def webhook
		#學說話
		reply_text = learn(received_text)

		#關鍵字回覆
		reply_text = keyword_reply(received_text) if reply_text.nil?
		# 設定回覆訊息
        #reply_text = keyword_reply(received_text)
      
        # 傳送訊息到line
        response = reply_to_line(reply_text)

        # 回應 200
        head :ok
    end 

    #取得對方的話
    def received_text
    	message = params['events'][0]['message']
    	message['text'] unless message.nil?
    end

    #學說話
    def learn(received_text)
    	#如果開頭不是 小狐學說話; 就跳出
    	return nil unless received_text[0..5] == '小狐學說話;'

    	received_text = received_text[6..-1]
        semicolon_index = received_text.index(';')

        # 找不到分號就跳出
        return nil if semicolon_index.nil?

        keyword = received_text[0..semicolon_index-1]
        message = received_text[semicolon_index+1..-1]

        KeywordMapping.create(keyword: keyword, message: message)
        '好哦～好哦～'
    end

    #關鍵字回覆
    def keyword_reply(received_text)
    	#--------------分隔線--------------------
    	#學習紀錄表
    	#keyword_mapping = {
    	#	'QQ' => '神曲支援：https://www.youtube.com/watch?v=T0LfHEwEXXw&feature=youtu.be&t=1m13s',
    	#	'我難過' => '神曲支援：https://www.youtube.com/watch?v=T0LfHEwEXXw&feature=youtu.be&t=1m13s'
    	#}
    	#查表
    	#keyword_mapping[received_text]  
    	#如果 &. 的前面是 nil，那他就不會做後面的事，直接傳回 nil
    	KeywordMapping.where(keyword: received_text).last&.message  	
    end

    #傳送訊息到line
    def reply_to_line(reply_text)
        reply_text = '小狐不懂這是什麼意思呢~' if reply_text.nil?

    	# 取得 reply token
    	reply_token = params['events'][0]['replyToken']
    	#p "======這裡是 reply_token ======"
        #p reply_token 
        #p response
        #p response.body
        #p "============"

        # 設定回覆訊息
       message = {
       	type: 'text',
       	text: reply_text
       }

        # 傳送訊息
        line.reply_message(reply_token, message)
    end

    # Line Bot API 物件初始化
    def line
    #如果 @line 有值的話，直接回傳 @line，沒有值的話才作 Line::Bot::Client.new 並保存到 @line。
        @line ||= Line::Bot::Client.new { |config|
            config.channel_secret = '51e8b8e9ca81ab08cc54a66188e35dfe'
            config.channel_token = 'JzQkXBobsKSS7CQkHV15leq0JIdROKElvtS8dzYYI/wINUGoyCTidxc5Yd8q8CbsTUlJSA3Pe/YxERmD/68w9bNuM5CyCBo4gunoiRLT07h5fBlwYxtarNfpvRsz43TxCUYuN//F2JN+DuO4Ht3SWQdB04t89/1O/w1cDnyilFU='
        }
    end
	


	def eat
		render plain: "吃冰"
	end

	def request_headers
		render plain: request.headers.to_h.reject{ |key, value|
			key.include? '.'
	}.map{ |key, value|
			"#{key}: #{value}"
		}.sort.join("\n")
	end

	def response_headers
		response.headers['7878'] = 'QQ'
		render plain: response.headers.to_h.map{ |key, value|
			"#{key}: #{value}"
		}.sort.join("\n")
	end

	def request_body
		render plain: request.body
	end

	def show_response_body
		puts "===這是設定前的response.body:#{response.body}==="
    	render plain: "虎哇花哈哈哈"
    	puts "===這是設定後的response.body:#{response.body}==="
    end

    def sent_request
    	require 'net/http'
        uri = URI('http://localhost:3000/smallfox/eat')
    	http = Net::HTTP.new(uri.host, uri.port)
    	http_request = Net::HTTP::Get.new(uri)
    	http_response = http.request(http_request)

    	render plain: JSON.pretty_generate({
      		request_class: request.class,
      		response_class: response.class,
      		http_request_class: http_request.class,
      		http_response_class: http_response.class
    	})
    end

    def translate_to_korean(message)
    	"#{message}油~"
  	end
    
end