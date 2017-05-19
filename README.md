fort_depend.py
==============

A python script to generate Fortran dependencies

Original script by D. Dickinson

Usage
=====

Here's an example of how to use `fort_depend.py` in your makefiles.

Input parameters:


   -f  --files        Files to process
   -o  --output       Output file
   -v -vv -vvv        Different level of verbosity contained in standard output
   -w  --overwrite    Overwrite output file without warning
   -r --root_dir      Project root directory
   -d --dep_dir       List of selected dependecy directories

For bigger project example, look at Makefiles, rule.mk, src_dir_path.mk and other files in fll project at
https://github.com/libm3l/fll which is a linked list library written in Fortran and which uses this 
script to get fortran project dependencies

=========================  MAKEFILE EXAMPLE  ===================

    # Script to generate the dependencies
    #  for example - look into www.github.com/libm3l/fll project
    #
    #  specify location of fort_depend.py script
    #
    MAKEDEPEND=/path_to/fort_depend.py
    #
    #  The PROJ_ROOT_PATH specifies the common directory for all the project subdirectories
    #  specify location of fortran project root directory
    #  the script can now make dependencies for project with source
    #  files located in different subdirectories directories in the project root directory. 
    #  The script lops over all of them finding dependencies for all fortran files 
    #  use option --root_dir
    #
    PROJ_ROOT_PATH =/path/to_proj_root_dir
    #
    #  specify selected path for dependency search, ie. for big projects, rather then search through all directories in PROJ_ROOT_PATH
    #  you can specify those directories which will be searched for dependencies are located
    #  if not specified, the script will be searching through entire tree. For bigger projects this may lead to longer time while 
    #  looking for dependencies
    #  use option --dep_dir
    #

    # $(DEP_FILE) is a .dep file generated by fort_depend.py
    DEP_FILE = my_project.dep

    # Source files to compile
    # You can specify all .f90 files
    FFILES= $(notdir $(wildcard $(srcdir)/*.f90))
    # or you can specify names of the files directly
    FFILES = mod_file1.f90 \
             mod_file2.f90

    #
    # files specified in FFILES are dependent on files located in directory ../data_util and ../../util
    # if not specified, the sript looks for all files in  PROJ_ROOT_PATH
    FMODDIRS= \
    ../data_util \
    ../../util \

    # Make sure everything depends on the .dep file
    all: $(actual_executable) $(DEP_FILE)

    # Make dependencies
    .PHONY: depend
    depend: $(DEP_FILE)

    # The .dep file depends on the source files, so it automatically gets updated
    # when you change your source
    $(DEP_FILE): $(OBJECTS)
        @echo "Making dependencies!"
        cd $(srcdir) && $(MAKEDEPEND) -r  $(PROJ_ROOT_PATH)  -d $(FMODDIRS) -v w -o $(srcdir)/$(DEP_FILE) -f $(FFILES)
        
    -include $(DEP_FILE)
