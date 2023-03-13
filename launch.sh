#! /usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem='20gb'
#SBATCH --time='01:00:00'
#SBATCH --constraint=sd
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

current=`pwd`
scripts_path=$current/scripts
export PATH=$scripts_path:$PATH
mkdir -p $current/results/cohortAn

if [ "$1" == "1" ]; then
	echo 'Prepare PMM2 file & execute Cohort Analyzer'
	parse_pmm2_file.rb -i $current/data/pmm2_patients_info.txt -o $current/results/pmm2_paco_format.txt
	dataset=$current/results/pmm2_paco_format.txt
	source ~soft_bio_267/initializes/init_pets
	coPatReporter.rb -i $dataset -o $current/results/cohortAn/pmm2 -p phenotypes -c chr -d patient_id -C 25 -s start -e stop -S ',' -m lin -T 2
fi

if [ "$1" == "2" ]; then
	echo 'Execute ExpHunter Suite'
	source ~soft_bio_267/initializes/init_autoflow
	packages='WDE'
	final_counts_folder=''
	resultsPath=/mnt/scratch/users/bio_267_uma/josecordoba/NGS_projects/pmm2_belen
	targetPath=/mnt/home/users/bio_267_uma/josecordoba/proyectos/pmm2_belen
	datasets=( '2016' '2020' )
	for dataset in "${datasets[@]}"
	do
		if [[ "$dataset" == '2016'  ]]; then
			target=$targetPath/mRNAseq_$dataset/analysis/DEG_workflow/TARGETS/CTL_vs_MUT_target.txt
			aux_target=$targetPath/mRNAseq_$dataset/analysis/DEG_workflow/TARGETS/CTL_vs_MUT_target.aux
		elif [[ "$dataset" == '2020'  ]]; then
			target=$targetPath/mRNAseq_$dataset/analysis/DEG_workflow/TARGETS/CTL_vs_HIGH_bicor_fil_target.txt
			aux_target=$targetPath/mRNAseq_$dataset/analysis/DEG_workflow/CTL_vs_HIGH_bicor_fil_target.txt

		fi
		var_info=`echo -e "\\$target=$target,
			\\$aux_target=$aux_target,
			\\$packages=$packages,
			\\$final_counts=$resultsPath/mRNAseq_$dataset/DEGenesHunter_results/CTL_vs_MUT/final_counts.txt,
			\\$dataset=$dataset" | tr -d '[:space:]' `
		#echo $var_info
		AutoFlow -w templates/exprAnalysis.af -t '7-00:00:00' -m '100gb' -c 4 -o $current/results/$dataset -n 'sr' -e -V $var_info $2
	done

fi