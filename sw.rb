#!/usr/bin/env ruby

###
# Copyright (c) 2014 Matthew Harvey
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
###

require 'yaml'

module TimeConversion
  
  def self.seconds_to_hours(hours)
    hours / 60.0 / 60.0
  end

  def self.local_time_string(date_time_string)
    # TODO Make this less of a hack.
    date_time_string.localtime.to_s[11..18]
  end
end

module Formatting

  def self.nice_hours(hours, decimal_places)
    s = hours.round(decimal_places).to_s
    parts = s.split('.')
    frac = parts[1]
    frac = Formatting.pad_right(frac, 3, "0")
    parts[0] + "." + frac
  end

  def self.pad_right(original, target_width, character)
    ret = original.to_s
    while ret.length < target_width
      ret << character
    end
    ret
  end
end

class Stopwatch
  
  def initialize(filepath)
    @filepath = filepath
    @times = []
    load 
  end

  def running
    @times.size.odd?
  end

  def reset
    stop if running
    stats
    silent_reset
    puts "\nStopwatch has been reset."
  end

  def start
    if running
      puts "Stopwatch is already running."
    else
      @times << Time.new
    end
    save
  end

  def stop
    if running
      @times << Time.new
    else
      puts "Stopwatch is not running."
    end
    save
  end

  def silent_reset
    @times = []
    save
  end

  def stats

    # TODO Make this less of a mess. Could control it via a Table and
    # Column class. Would make it more maintainable and configurable and could
    # probably be reused in other command line projects.

    # TODO Should output time elapsed both in hours+minutes, and
    # in decimal hours.

    def nice_hours(hours)
      Formatting.nice_hours(hours, rounding)
    end

    return if @times.empty?
    puts    "BEGIN     END       HOURS  CUMULATIVE"
    i = 0
    cumulative_hours = 0.0
    original_start_time = @times[0]
    while i < @times.size
      start_time = @times[i]
      stop_time = ((i + 1 < @times.size)? @times[i + 1]: Time.new)
      hours = TimeConversion.seconds_to_hours(stop_time - start_time)
      cumulative_hours += hours
      start_time_s = TimeConversion.local_time_string(start_time)
      stop_time_s = TimeConversion.local_time_string(stop_time)
      print "#{start_time_s}  #{stop_time_s}"
      print ((running && (i + 1 == @times.size))? "*": " ")
      print " "
      puts "#{nice_hours(hours)}  #{nice_hours(cumulative_hours)}"
      i += 2
    end
    hours_inc_breaks =
      TimeConversion.seconds_to_hours(stop_time - original_start_time)
    total_breaks = hours_inc_breaks - cumulative_hours
    puts ""
    puts "Gross hours elapsed:       #{nice_hours(hours_inc_breaks)}"
    puts "Breaks:                    #{nice_hours(total_breaks)}"
    puts "Net hours elapsed:         #{nice_hours(cumulative_hours)}"
    puts "\n*Stopwatch is still running." if running
  end

  private
    
    def rounding
      3
    end

    def save
      File.open(@filepath,'w') { |file| file.puts(@times.to_yaml) }
    end

    def load
      @times = YAML.load(File.read(@filepath)) if File.exists?(@filepath)
    end

end

module Persistence
  
  def self.default_filepath
    File.join(Dir.home, ".sw.yml")
  end
end

module CommandProcessor

  def self.print_usage
    print <<-EOF.gsub(/^ */, '')
      Usage:

      sw start    Start the stopwatch
      sw stop     Stop the stopwatch
      sw reset    Output stats, and reset the stopwatch to zero
      sw stats    Output stats without resetting the stopwatch
      sw help     Print this help message
      EOF
  end

  def self.process_subcommand(subcommand)
    if [:start, :stop, :reset, :stats].include? subcommand
      stopwatch = Stopwatch.new(Persistence.default_filepath)
      stopwatch.send(subcommand)
    elsif subcommand == :help
      print_usage
    else
      print "Unrecognized subcommand: #{subcommand}\n\n"
      print_usage
    end
  end

  def self.main
    if ARGV.size == 1
      process_subcommand(ARGV[0].to_sym)
    else
      print "Incorrect number of arguments.\n\n"
      print_usage
    end
  end
end

CommandProcessor.main
