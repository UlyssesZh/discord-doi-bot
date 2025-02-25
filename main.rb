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
	content.scan(%r{https?://doi\.org/(\S+)|doi:(\S+)}i).map do |match|
		match.compact.first.gsub %r{^/+|/+$}, ''
	end.uniq
end

bot.message do |event|
	embed = doi_from_message(event.content).map { embed_from_doi _1 }.compact
	next if embed.empty?
	components = Discordrb::Webhooks::View.new
	components.row do |row|
		row.button style: :secondary, emoji: {name: '❌'}, custom_id: "delete_#{event.user.id}"
	end
	event.message.reply! '', embed:, components:
end

bot.button do |event|
	next unless user_id = event.custom_id[/^delete_(\d+)$/, 1]
	next unless event.user.id == user_id.to_i
	event.message.message.delete
end

bot.run
