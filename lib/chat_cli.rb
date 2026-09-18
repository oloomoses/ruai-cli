require "openai"
require "dotenv/load"
require "tty-prompt"
require "tty-markdown"

class ChatCli
    MODEL = "gpt-4o-mini"
    SYSTEM_PROMPT = "You are my helpful assistant"

    def initialize(model: MODEL, system_prompt: SYSTEM_PROMPT)
        @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
        @prompt = TTY::Prompt.new
        @model = model
        @system_prompt = system_prompt

        reset_conversation
    end

    def start
        print_welcome

        loop do
            user_input = ask_user

            case user_input.strip.downcase
            when "exit", "quit"
                puts "Goodbye"
                break
            when "clear"
                reset_conversation
                next
            end

            chat_user(user_input)
        end
    end



    private

    def chat_user(user_input)
        @messages << { role: "user", content: user_input }

        begin
            response = @client.chat(
                parameters: {
                    model: @model,
                    messages: @messages,
                    temperature: 0.7
                }                
            )
        
            assistant_reply = response.dig("choices", 0, "message", "content")
            @messages << {role: "assistant", content: assistant_reply }
            puts "\nAssistant >"
            puts TTY::Markdown.parse(assistant_reply)
            puts

        rescue => e
            puts TTY::Markdown.parse("Error: #{e.message}")
            @messages.pop  
        end
    end

    def ask_user
        @prompt.ask("You >") { |q| q.required true }
    end

    def print_welcome
        puts "OpenAI Chat CLI (#{@model})"
        puts "Type 'exit', 'quit' or Ctrl + C to leave. \n "
        puts "Type 'clear' to reset conversation \n\n"
    end

    def reset_conversation
        @messages = [{role: "system", content: @system_prompt}]
    end
end