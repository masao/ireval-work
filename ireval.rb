#!/usr/local/bin/ruby
# $Id$

# 仮想qrels: 全てランダムで作った。
#bpref10 を計算してみる。
#pool の作成は全Runの先頭5件づつ。

N = 1000	# 文書総数
MAX = 100	# 1Runの提出件数
RUNS = 20	# Run数
R = 20	# 適合文書数
base = (1..N).sort{ rand <=> rand }
run = []; RUNS.times{|i| run[i] = Array.new(MAX).map{ base[rand(base.size)] }.uniq}
pool = run.map{|e|e[0,10]}.flatten.uniq.sort
rel = pool.sort{|a,b|rand<=>rand}[0,R].sort

def prec(run, rel, n) # Precision at N
   run[0,n].select{|e| rel.include? e }.size / n.to_f
end

def ap(run, rel) # Average Precision
   prec = 0
   hit = 0
   run.map{|e| rel.include? e }.each_with_index do |d, rank|
      if d
         hit += 1
         prec += hit / (rank+1).to_f
      end
   end
   prec / rel.size
end

def bpref(run, rel, pool) # proposed by C. Buckley
   nonrel = pool - rel
   pref = 0
   rel.each do |d|
      rank = run.index(d)
      rank ||= run.size
      pref += 1 - run[0, rank].map{|e| nonrel.include? e }.compact[0,rel.size].size / rel.size.to_f
   end
   pref / rel.size
end

def bpref10(run, rel, pool) # proposed by C. Buckley
   nonrel = pool - rel
   pref = 0
   run.map{|e| rel.include? e }.each_with_index do |d, rank|
      if d
         pref += 1 - run[0,rank].map{|e| nonrel.include? e }.compact[0,rel.size+10].size / (rel.size+10).to_f
      end
   end
   pref / rel.size
end

class Array
   def to_pref_s(rel, pool)
      self.map{|e|
         if rel.include? e
            "r"
         elsif pool.include? e
            "n"
         else "-"
         end
      }.join("")
   end
end

if $0 == __FILE__
   puts "QRELs:"
   RUNS.times{|i| puts run[i].to_pref_s(rel,pool) }

   puts "prec(10):"
   RUNS.times{|i| puts prec(run[i],rel,10)}
   puts "aprec:"
   RUNS.times{|i| puts ap(run[i],rel)}
   puts "bpref10:"
   RUNS.times{|i| puts bpref10(run[i],rel,pool)}
   # RUNS.times{|i| puts "#{i}:\t#{prec(run[i],rel,10)}\t#{ap(run[i],rel)}\t#{bpref10(run[i],rel,pool)}"}

   puts "Ranking Runs by measures:"
   puts "prec(10):"
   puts (0...RUNS).sort{|a,b| prec(run[b],rel,10) <=> prec(run[a],rel,10) }
   puts "aprec:"
   puts (0...RUNS).sort{|a,b| ap(run[b],rel) <=> ap(run[a],rel) }
   puts "bpref10:"
   puts (0...RUNS).sort{|a,b| bpref10(run[b],rel,pool) <=> bpref10(run[a],rel,pool) }
end
