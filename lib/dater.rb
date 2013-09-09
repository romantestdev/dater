# coding: utf-8
require 'date'
require_relative "dater/version"

module Dater
  
	class Resolver
		
		attr_accessor :format, :lang

		DICTIONARY = {
			day:  		{ "en"=>/days/, 		"es" => /(dias|días)/,"pt" => /dias/, 	:mult =>	86400},
			week: 		{ "en"=>/weeks/, 		"es" => /semanas/, 		"pt" => /semanas/, :mult =>	604800},
			month: 		{ "en"=>/months/,		"es" => /meses/, 			"pt" => /meses/, 	:mult =>  2592000},
			year: 		{ "en"=>/years/, 		"es" => /años/, 			"pt" => /anos/, 	:mult =>  31536000},
			today: 		{ "en"=>'today', 		"es" => 'hoy', 				"pt" => 'hoje' 	},
			tomorrow: { "en"=>'tomorrow', "es" => 'mañana',			"pt" => 'manhã' 	},
			yesterday:{ "en"=>'yesterday',"es" => 'ayer', 			"pt" => 'ontem' 	}
		}

		# Creates a Dater::Resolver object
		#
		# Param [String] format = date format
		# Param [String] lang = languaje for matching (en=english, es=spanish, pt=portuguese)
		def initialize(format='%Y-%m-%d', lang="en")
			@format=format
			@lang=lang if ["en","es","pt"].include? lang
		end

		# Convert the period of time passed as argument to the configured format
		#
		# Param [String] period = a period of time like "in 3 days" or "in 10 months" or "in 2 years". It could be a formatted date to convert to the wanted format
		# Return [String] converted date to the configured format. If period is nil, returns date for tomorrow 
		def for(period=nil)
			return (Time.now).strftime(@format) if period.nil?
			@date=case period.downcase 	
			when DICTIONARY[:today][@lang]
				self.today(false)
			when DICTIONARY[:tomorrow][@lang]
				self.tomorrow(false)
			when DICTIONARY[:yesterday][@lang]
				self.yesterday(false)
			when /\d+.\d+.\d+/
				time_from_date(period)	
			when /\d+\s.+/
				Time.now+period.scan(/\d+/)[0].to_i*multiply_by(period)
			else
				return period
			end
			 # unless parts.nil?
			return @date.strftime(@format)
		end

		def para(period)
			self.for(period)
		end

		def today(formatted=true)
			time=Time.now
			time=time.strftime(@format) if formatted
			time
		end

		def hoy
			self.today(true)
		end

		def hoje
			self.today(true)
		end

		def yesterday(formatted=true)
			time = one_day_diff(false)
			time = time.strftime(@format) if formatted
			time
		end

		def ayer
			self.yesterday(true)
		end

		def ontem
			self.yesterday(true)
		end

		def tomorrow(formatted=true)
			time = one_day_diff(true)
			time=time.strftime(@format) if formatted
			time
		end

		def mañana
			self.tomorrow(true)
		end

		def manhã
			self.tomorrow(true)
		end

		def one_day_diff(plus=true)
			time=Time.now
			diff = DICTIONARY[:day][:mult]
			plus ? time+diff : time-diff
		end

	private

		def is_day?(period)
			true if period.scan(DICTIONARY[:day][@lang]).size > 0
		end

		def day_mult(period)
			DICTIONARY[:day][:mult] if is_day?(period)			 
		end

		def is_week?(period)
			true if period.scan(DICTIONARY[:week][@lang]).size > 0
		end

		def week_mult(period)
			DICTIONARY[:week][:mult] if is_week?(period)
		end

		def month_mult(period)
			DICTIONARY[:month][:mult] if is_month?(period)
		end

		def is_month?(period)
			true if period.scan(DICTIONARY[:month][@lang]).size > 0
		end

		def year_mult(period)
			DICTIONARY[:year][:mult] if is_year?(period)
		end

		def is_year?(period)
			true if period.scan(DICTIONARY[:year][@lang]).size > 0
		end

		# Set true the matched keyword in a given string
		# 
		# Param [String] period = the period of time expressed in a literal way
		# Param [String] lang = the languaje to eval
		# Return [Hash] times
		def multiply_by(period)

			return day_mult(period) || week_mult(period) || month_mult(period) || year_mult(period) || 1
			# mult = 1 
			# mult = DICTIONARY[:day][:mult] if day_mult(period)
			# mult = DICTIONARY[:week][:mult] if week_mult(period)
			# mult = DICTIONARY[:month][:mult] if month_mult(period)
			# mult = DICTIONARY[:year][:mult] if year_mult(period)
			# return mult
		end

		
		# Return the Time object according to the splitted date in the given array  
		# |
		# Param [Array] date = date splitted
		# Return [Time] 
		def time_from_date(date)
			numbers=date.scan(/\d+/).map!{|i| i.to_i}
			day=numbers[2-numbers.index(numbers.max)]
			Date.new(numbers.max,numbers[1],day).to_time 
		end
	end
end