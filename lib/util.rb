
class String
	def cleanup
		indent = (index /^([ \t]+)/; $1) || ''
		regex = /^#{Regexp::escape( indent )}/
		strip.gsub regex, ''
	end

	def oneline
		strip.gsub( /\n\s+/, '' )
	end
end
