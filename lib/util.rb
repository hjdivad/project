
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


class Object
	# Deep duplicate via remarshaling.  Not always applicable.
	def ddup
		Marshal.load( Marshal.dump( self ))
	end
end

