require "dotenv/load"
require "openai"
require "tty-prompt"
require "tty-markdown"

MODEL = "gpt-4o-mini"
SYSTEM_PROMPT = "You are a helpful assistant"

client = OpenAI::Client.new(
    access_token: ENV.fetch("OPENAI_API_KEY")
)

prompt = TTY::Prompt.new
messages = [{role: "system", content: SYSTEM_PROMPT}]

puts "OpenAI Chat CLI (#{MODEL})"
puts "Type 'exit', 'quit' or Ctrl + C to leave. \n Type 'clear' to reset the conversation \n\n"

loop do
    user_input = prompt.ask("You >") do |q|
        q.required true
    end

    case user_input.strip.downcase
    when "exit", "quit"
        puts "Goodbye"
        break
    when "clear"
        messages = [{role: "system", content: SYSTEM_PROMPT }]
        puts "Conversation cleared. \n"
        next
    end

    messages << {role: "user", content: user_input }


    begin
        response = client.chat(
            parameters: {
                model: MODEL,
                messages: messages,
                temperature: 0.7
            }
        )

        assistant_reply = response.dig("choices", 0, "message", "content").to_s
        messages << { role: "assistant", content: assistant_reply }

        puts "\nAssistant >"
        puts TTY::Markdown.parse(assistant_reply)
        puts

    rescue => e
        puts TTY::Markdown.parse("Error: #{e.message}")
        messages.pop
    
    end
end