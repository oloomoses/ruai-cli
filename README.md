# ruai-cli

A small Ruby command-line chat client for OpenAI's Chat Completions API. The
interactive client keeps the conversation in memory, renders Markdown replies
in the terminal, and provides a command to reset the conversation.

## Requirements

- Ruby 3.1 or newer
- Bundler
- An OpenAI API key

## Setup

Clone the repository and install its Ruby dependencies:

```sh
bundle install
```

Create a `.env` file in the project root and add your API key:

```dotenv
OPENAI_API_KEY=your_api_key_here
```

Keep `.env` out of version control. API usage is billed to the OpenAI account
associated with the key.

## Interactive chat

Start the main CLI with:

```sh
bundle exec ruby bin/chat.rb
```

The client uses `gpt-4o-mini` by default and starts each session with the
system prompt `You are a helpful assistant`. Enter a message at the `You >`
prompt to send it to OpenAI.

### Commands

| Input | Action |
| --- | --- |
| `clear` | Remove the current conversation history and start over |
| `exit` | End the session |
| `quit` | End the session |
| `Ctrl-C` | End the session immediately |

Conversation history is held in memory only; closing the process deletes it.
Each new request includes the previous messages, so longer conversations use
more tokens.

## Minimal HTTP example

`raw_chat.rb` is a dependency-free example of the underlying request using
Ruby's standard library. It sends one hard-coded question and prints the
response:

```sh
ruby raw_chat.rb
```

It reads `OPENAI_API_KEY` from the process environment, but does not load
`.env` itself. To run it with the same `.env` file, load the variable first:

```sh
set -a
. ./.env
set +a
ruby raw_chat.rb
```

For normal use, prefer `bin/chat.rb`, which loads `.env` automatically and
handles an ongoing conversation.

## Configuration

The interactive client's model and system prompt are constants near the top of
`bin/chat.rb`:

```ruby
MODEL = "gpt-4o-mini"
SYSTEM_PROMPT = "You are a helpful assistant"
```

Change these values to use a different supported model or assistant behavior.
The client currently sends `temperature: 0.7` with each request.

## Project layout

```text
.
├── bin/
│   └── chat.rb       # Interactive chat client
├── raw_chat.rb       # Minimal Net::HTTP request example
├── Gemfile           # Ruby dependencies
└── README.md
```

## Troubleshooting

**`KeyError: key not found: OPENAI_API_KEY`**

The interactive client could not find the API key. Confirm that `.env` is in
the project root and contains `OPENAI_API_KEY=...`, or export the variable in
your shell before running the command.

**Authentication or API errors**

Check that the key is valid, active, and authorized to use the selected model.
Also verify that the account has available usage or billing configured.

**Dependency errors**

Run `bundle install` from the repository root and then retry with
`bundle exec ruby bin/chat.rb`.

## Security

Never commit `.env` or paste an API key into source code. If a key is exposed,
revoke it in the OpenAI dashboard and create a replacement.
