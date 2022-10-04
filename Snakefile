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


            
rule all:
    input:
        expand(
            rules.bet.output,
            zip,
            **inputs.input_zip_lists['t1']
        )

