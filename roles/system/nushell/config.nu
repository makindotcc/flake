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

$env.PROMPT_COMMAND = { $"(sys host | get hostname) (pwd)" }
