using ArgParse

struct Commandline
    command_ok::Bool                 # Boolean the check if the line of command is valid
    cpu_time::Int                    # Allocated CPU time (defaults to 5min)
    seed::Int                        # Random seed (defaults to 0, in this case the current time value will be used as seed)
    instance_path::String            # Instance path
    output_path::String              # Output path
end

# Constructor of struct Commandline
function Commandline()
    """
    Read command line arguments.
    """

    s = ArgParseSettings()

    @add_arg_table s begin
        "instance_path"
            help = "Path to instance."
            arg_type = String
            required = true
        "--cpu_time","-t"
            help = "CPU time in seconds (defaults to 300s)."
            arg_type = Int
            default = 300
        "--sol"
            help = "File where to output the solution statistics (defaults to the instance file name prepended with 'sol-')."
            arg_type = String
        "--seed"
            help = "Random seed (defaults to 0, in this case the current time value will be used as seed)"
            arg_type = Int
            default = 0
    end

    args = parse_args(s)

    # If no output path is specified then save solution in "outputs" folder with the same name as the instance
    if args["sol"] == nothing
        instance_name = split(args["instance_path"],'/')[end]
        args["sol"] = "../outputs/sol-"*instance_name
    end

    c = Commandline(true, args["cpu_time"], args["seed"], args["instance_path"], args["sol"])
    return c
end