$env.config = {
    show_banner: false

    rm: {
        always_trash: true
    }

    history: {
        file_format: "sqlite"
        isolation: true
    }

    completions: {
        algorithm: "prefix"    # prefix or fuzzy
    }
}

let default_prompt_cmd = $env.PROMPT_COMMAND
$env.PROMPT_COMMAND = { 
    let original_prompt = (do $default_prompt_cmd)
    $"(sys host | get hostname) ($original_prompt)"
}
