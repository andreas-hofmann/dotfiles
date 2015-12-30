def configure(repl):
    """
    Configuration method. This is called during the start-up of ptpython.
    :param repl: `PythonRepl` instance.
    """

    repl.show_signature = True
    repl.show_docstring = False
    repl.show_meta_enter_message = True
    repl.highlight_matching_parenthesis = True
    repl.wrap_lines = True
    repl.enable_mouse_support = True
    repl.complete_while_typing = True
    repl.enable_fuzzy_completion = True
    repl.enable_dictionary_completion = True
    repl.vi_mode = True
    repl.use_code_colorscheme("material")
