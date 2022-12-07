execute = isempty(ARGS) || ARGS[1] == "run"

org, reps = :JuliaImageRecon, :About
eval(:(using $reps))
using Documenter
using Literate

# https://juliadocs.github.io/Documenter.jl/stable/man/syntax/#@example-block
ENV["GKSwstype"] = "100"
ENV["GKS_ENCODING"] = "utf-8"

# generate examples using Literate
lit = joinpath(@__DIR__, "lit")
src = joinpath(@__DIR__, "src")
gen = joinpath(@__DIR__, "src/generated")

base = "$org/$reps"
repo_root_url =
    "https://github.com/$base/blob/main/docs/lit"
nbviewer_root_url =
    "https://nbviewer.org/github/$base/tree/gh-pages/dev/generated"
binder_root_url =
    "https://mybinder.org/v2/gh/$base/gh-pages?filepath=dev/generated"


repo = eval(:($reps))
DocMeta.setdocmeta!(repo, :DocTestSetup, :(using $reps); recursive=true)

for (root, _, files) in walkdir(lit), file in files
    splitext(file)[2] == ".jl" || continue # process .jl files only
    ipath = joinpath(root, file)
    opath = splitdir(replace(ipath, lit => gen))[1]
    Literate.markdown(ipath, opath; documenter = execute, # run examples
        repo_root_url, nbviewer_root_url, binder_root_url)
    Literate.notebook(ipath, opath; execute = false, # no-run notebooks
        repo_root_url, nbviewer_root_url, binder_root_url)
end


# Documentation structure
ismd(f) = splitext(f)[2] == ".md"
pages(folder) =
    [joinpath("generated/", folder, f) for f in readdir(joinpath(gen, folder)) if ismd(f)]

isci = get(ENV, "CI", nothing) == "true"

format = Documenter.HTML(;
    prettyurls = isci,
    edit_link = "main",
    canonical = "https://$org.github.io/$repo/stable/",
    assets = ["assets/custom.css"],
)

makedocs(;
    modules = [repo],
    authors = "Jeff Fessler and contributors",
    sitename = "$repo",
    format,
    pages = [
        "Home" => "index.md",
        "Methods" => "methods.md",
        "Examples" => pages(""),
    ],
)

if isci
    deploydocs(;
        repo = "github.com/$base",
        devbranch = "main",
        devurl = "dev",
        versions = ["stable" => "v^", "dev" => "dev"],
        forcepush = true,
#       push_preview = true,
        # see https://$org.github.io/$repo/previews/PR##
    )
end
