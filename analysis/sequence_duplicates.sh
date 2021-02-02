
makeblastdb -in sequences_holo.fasta -dbtype prot
blastp -query sequences_holo.fasta -db sequences_holo.fasta -out seq_holo_test.tab -outfmt 6

