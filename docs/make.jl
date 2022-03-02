using LTVmodel
using Documenter

DocMeta.setdocmeta!(LTVmodel, :DocTestSetup, :(using LTVmodel); recursive=true)

makedocs(;
    modules=[LTVmodel],
    authors="Mamta <mamta16@nmsu.edu> and contributors",
    repo="https://github.com/mantodas/LTVmodel.jl/blob/{commit}{path}#{line}",
    sitename="LTVmodel.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mantodas.github.io/LTVmodel.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mantodas/LTVmodel.jl",
    devbranch="main",
)
