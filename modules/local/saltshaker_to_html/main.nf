process SALTSHAKER_TO_HTML {
    tag "$meta.id"
    label "process_low"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/2f/2fdb3ffa4bac62e98ec062e991217df2ab96e67bbd45a502bd25ff2effecb96e/data':
        'community.wave.seqera.io/library/htslib_python:d1e4474cbf76f4e9' }"

    input:
    tuple val(meta), path(classify)

    output:
    tuple val(meta), path("*.html"), emit: classify_html

    script:
    """
    python3 << 'EOF'
    import re
    def saltshaker_txt_to_html(txt_file):
        with open(txt_file) as f:
            content = f.read()
        html_content = re.sub(r'\\n', '<br>', content)
        return html_content

    html = saltshaker_txt_to_html("${classify}")
    with open("${classify.baseName}.html", 'w') as f:
        f.write('<html><body>')
        f.write(f'<pre style="padding: 15px; border-radius: 5px; overflow-x: auto;">{html}</pre>')
        f.write('</body></html>')
    EOF
    """
}
