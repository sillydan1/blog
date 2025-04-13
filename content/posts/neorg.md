+++
date = '2024-11-27'
draft = true
title = 'Moving Away From Neorg'
tags = ['tutorial']
categories = ['technical', 'life']
+++

Neorg is a great neovim plugin, but it's in that awkward state that many free and open source projects are in where
it's only actively maintained by one guy, and the whole thing is apparently undergoing a rewrite. For me it was a bit
of a honeypot trap, as I saw the tagline **"Modernity meets insane extensibility"** and thought that there surely was
many, easy to use plugins that could extend the default functionality. There's obviously the great `awesome` list for
neorg [here](https://github.com/nvim-neorg/awesome-neorg) but most of these plugins have been abandonned or won't work
well with the new rewrite.
Don't get me wrong, the default neorg experience is actually amazing and the syntax is clearly (subjectively) superior
to regular emacs org-mode, but I'm not sure if either of those can compete with the increasingly standardized markdown
syntax. In any case, when you are trusting your most personal inner thoughts with a syntax, you should really strive
to use something that has (Neorg actually fails in both of these points):

1. Survived the bathtub curve, and
2. Won't lock you down to a specific tool.

The second point is probably the most important one. A general life-advise that I first heard from Luke Smith is that
whenever you have a life decision to make, you should favor the choice that maximises your personal freedom. i.e. If
one of the choices limit you to only being able to do a thing in one way, using only one tool, provided, managed and
maintained by one entity (company or person) and the other enables you to do the thing however you want. Or at least
you can do the thing in multiple ways. You should strongly prefer the second option - even if it's a bit less
convenient and less sleek or sexy.

We got a bit off track there. Let's get back to how to migrate away from Neorg. I have a couple of criteria for such a
tool that I need.

## Criteria

Any agenda-ing and kanban-ing will (and should) be done from a separate program. This <u>should</u> also be possible with
neorg, but the problem here is that the syntax is not that popular (yet), so not many programs actually support it.
Finding such programs is a separate tools-search though, and should be done based on the syntax decision.

- Conceal level (trivial if there's native treesitter support)
- Folding (`set foldmethod=expr` see [https://www.jmaguire.tech/posts/treesitter_folding/](https://www.jmaguire.tech/posts/treesitter_folding/))
- Quickly marking checklists as done (e.g. `<C-space>` or `<leader>td`)
- Standardized syntax that is widely used
- Pressing `<Return>` to follow links (create if not exists)
- `image.nvim` support - preferably through `snacks.nvim`

## Markdown

Just raw markdown might be the way to go. I can set `conceallevel=2` for prettier text whilst editing. There's only
a couple of things that I want that I might need to mold out using custom things.
- Follow links: [https://github.com/jghauser/follow-md-links.nvim](https://github.com/jghauser/follow-md-links.nvim)


### Converting from Neorg

Neorg have an integrated markdown exporter which works fairly okay. It gets links a bit messed up - especially if it
is a link to [another neorg file](#indexmd).

## Vimwiki

[plugin page](https://github.com/vimwiki/vimwiki)

This is a great plugin, but it is <u>just</u> a tad too "vim-pilled" and a bit difficult to get to do _excactly_ what I
want from a note-taking system. The primary issue is that `vimwiki_global_ext = 0` doesn't do the thing it says. The
`SYNTAX` is registered in neovim with as `vimwiki`, making any markdown based plugins useless. e.g. folding is
impossible to do (in a good way), because treesitter does not have a vimwiki parser, and if you set the syntax to
markdown, the actual syntax in the file is still not vimwiki.
This is a bit dissapointing, because vimwiki is actually <u>great</u>.

```lua
vim.g.vimwiki_list = {{
    syntax = "markdown",
    ext = ".md"
}}
vim.g.vimwiki_global_ext = 0

-- In your list of lazy.nvim plugins:
"vimwiki/vimwiki"
```

### Converting from Neorg

If using markdown as the vimwiki syntax, it should be the same procedure as [Markdown](#markdown). Otherwise, `pandoc` can
probably get you there if you use markdown as a middle-step.

## Org-mode

[plugin page](https://github.com/nvim-orgmode/orgmode).

This is using the traditional org-mode syntax. This used by almost all emacs users, so it'll make it easy to change
editor to emacs if I ever decide I want that. Neovim is nice and cool, but it's also very new and not even version 1
yet.

### Converting from Neorg

You can do a two-step conversion from `.norg` to `.markdown` (see [Markdown](#markdown)) to `.org` (see 
[https://emacs.stackexchange.com/questions/5465/how-to-migrate-markdown-files-to-emacs-org-mode-format](https://emacs.stackexchange.com/questions/5465/how-to-migrate-markdown-files-to-emacs-org-mode-format)).


# Conclusion


{{< centered image="/6616144.png" >}}
