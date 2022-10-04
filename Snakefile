from snakebids import bids, generate_inputs

configfile: 'config.yml'


# parse bids dataset with snakebids
inputs = generate_inputs(
    bids_dir=config["bids_dir"],
    pybids_inputs=config["pybids_inputs"],
    use_bids_inputs=True,
)



rule bet:
    input: 
        inputs.input_path['t1']
    output:
        bids(
            root='results',
            datatype='anat',
            desc='brain',
            suffix='T1w.nii.gz',
            **inputs.input_wildcards['t1']
        )
    container: config['singularity']['fsl']
    log:
        bids(
            root='logs',
            suffix='bet.log',
            **inputs.input_wildcards['t1']
        )
    shell: 'bet {input} {output}'


rule calc_avg_brain_size:
    input:
        brains=expand(rules.bet.output,
            zip,
            **inputs.input_zip_lists['t1'])
    output:
        txt=bids(
                root='results',
                suffix='avgbrainsize.txt',
                include_subject_dir=False,
                include_session_dir=False)
    run:
        brain_sizes = []
        for brain_nii in input.brains:
            data = nibabel.load(brain_file).get_data()
            brain_sizes.append((data != 0).sum())        
            
        with open(output.txt, 'w') as fp:
            fp.write("Average brain size is {avg} voxels".format(
                avg = np.array(brain_sizes).mean()))

            
rule all_participant:
    input:
        expand(
            rules.bet.output,
            zip,
            **inputs.input_zip_lists['t1']
        )
    default_target: True

rule all_group:
    input:
        rules.calc_avg_brain_size.output



