#!/usr/bin/env ruby
raise "usage: #{$0} NGRAM_SIZE" unless ARGV.length==1
NGRAM_SIZE = ARGV.first.to_i

def emit tuple
  puts tuple.join("\t")
end

STDIN.each do |line|
  terms = line.split(' ')

  terms.shift # id

  if (NGRAM_SIZE==1)
    terms.each { |t| puts t }
    next
  end

  next if terms.size < NGRAM_SIZE

  tuple = []
  NGRAM_SIZE.times { tuple << terms.shift }
  puts tuple.join(' ')

  while not terms.empty?
    tuple.shift
    tuple << terms.shift
    puts tuple.join(' ')
  end

end
