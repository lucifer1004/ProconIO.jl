using ProconIO
using Documenter

DocMeta.setdocmeta!(ProconIO, :DocTestSetup, :(using ProconIO); recursive=true)

makedocs(;
    modules=[ProconIO],
    authors="Gabriel Wu <wuzihua@pku.edu.cn> and contributors",
    repo="https://github.com/lucifer1004/ProconIO.jl/blob/{commit}{path}#{line}",
    sitename="ProconIO.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lucifer1004.github.io/ProconIO.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lucifer1004/ProconIO.jl",
    devbranch="main",
)
