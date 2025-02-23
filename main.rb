#!/usr/bin/env ruby

require 'serrano'
require 'discordrb'

Serrano.configuration do |config|
	if base_url = ENV['DISCORD_DOI_BOT_CROSSREF_BASE_URL']
		config.base_url = base_url
	end
	if mailto = ENV['DISCORD_DOI_BOT_CROSSREF_MAILTO']
		config.mailto = mailto
	end
end

if token = ENV['DISCORD_DOI_BOT_TOKEN']
	bot = Discordrb::Bot.new token:, intents: %i[server_messages direct_messages]
else
	abort "Missing DISCORD_DOI_BOT_TOKEN environment variable"
end

def embed_from_doi id
	begin
		works = Serrano.works ids: id
	rescue Serrano::NotFound
		return nil
	end
	return nil unless work = works.find { _1['status'] == 'ok' }&.[]('message')
	embed = Discordrb::Webhooks::Embed.new
	embed.title = work['title'].first
	cite = "#{work['container-title'].first} **#{work['volume']}**, #{work['page']} (#{work['issued']['date-parts'].first.first})"
	embed.description = "#{work['abstract']}\n\n#{cite}"
	authors = work['author'].map { "#{_1['given']} #{_1['family']}" }.join(', ')
	embed.author = Discordrb::Webhooks::EmbedAuthor.new name: authors[...256]
	embed.url = work['URL']
	embed.timestamp = Time.at work['created']['timestamp']/1000.0
	embed.footer = Discordrb::Webhooks::EmbedFooter.new text: work['DOI']
	return embed
end

def doi_from_message content
	[
		%r{https?://doi\.org/(?<id>\S+)}i,
		%r{doi:(?<id>\S+)}i,
	].each do |regex|
		if match = regex.match(content)
			return match[:id].gsub %r{^/+|/+$}, ''
		end
	end
	nil
end

bot.message do |event|
	next unless id = doi_from_message(event.content)
	if embed = embed_from_doi(id)
		event.message.reply! '', embed:
	else
		event.message.reply! "No metadata found for doi:#{id}"
	end
end

bot.run
