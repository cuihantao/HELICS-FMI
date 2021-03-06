/*

Copyright (C) 2017-2018, Battelle Memorial Institute
All rights reserved.

This software was co-developed by Pacific Northwest National Laboratory, operated by the Battelle Memorial
Institute; the National Renewable Energy Laboratory, operated by the Alliance for Sustainable Energy, LLC; and the
Lawrence Livermore National Laboratory, operated by Lawrence Livermore National Security, LLC.

*/

#include "argParser.h"
#include <fstream>
#include <iostream>
#include <boost/filesystem.hpp>
#include <boost/program_options.hpp>

namespace utilities
{
namespace po = boost::program_options;

static void loadArguments (po::options_description &config, const ArgDescriptors &argDefinitions)
{
    for (auto &addArg : argDefinitions)
    {
        switch (addArg.type_)
        {
        case ArgDescriptor::arg_type_t::flag_type:
            config.add_options() (addArg.arg_.c_str(), addArg.desc_.c_str());
            break;
        case ArgDescriptor::arg_type_t::string_type:
            config.add_options() (addArg.arg_.c_str(), po::value<std::string>(), addArg.desc_.c_str());
            break;
        case ArgDescriptor::arg_type_t::int_type:
            config.add_options() (addArg.arg_.c_str(), po::value<int>(), addArg.desc_.c_str());
            break;
        case ArgDescriptor::arg_type_t::double_type:
            config.add_options() (addArg.arg_.c_str(), po::value<double>(), addArg.desc_.c_str());
            break;
        case ArgDescriptor::arg_type_t::vector_string:
            config.add_options() (addArg.arg_.c_str(), po::value<std::vector<std::string>>(),
                addArg.desc_.c_str());
            break;
        case ArgDescriptor::arg_type_t::vector_double:
            config.add_options() (addArg.arg_.c_str(), po::value<std::vector<double>>(),
                addArg.desc_.c_str());
            break;
        }
    }
}

int argumentParser (int argc,
                     const char *const *argv,
                     variable_map &vm_map,
                     const ArgDescriptors &argDefinitions, const std::string &posName)
{
    po::options_description cmd_only ("command line only");
    po::options_description config ("configuration");
    po::options_description hidden ("hidden");

    
    // clang-format off
	// input boost controls
	cmd_only.add_options()
		("help,?", "produce help message")
        ("version,v","display a version string")
		("config-file", po::value<std::string>(), "specify a configuration file to use");
    // clang-format on

    loadArguments (config, argDefinitions);

    po::options_description cmd_line ("command line options");
    po::options_description config_file ("configuration file options");
    po::options_description visible ("allowed options");

    cmd_line.add (cmd_only).add (config);
    config_file.add (config);
    visible.add (cmd_only).add (config);

    if (!posName.empty())
    {
        hidden.add_options() (posName.c_str(), po::value<std::string>(), "positional argument");
        cmd_line.add(hidden);
        config_file.add(hidden);
    }
    
    variable_map cmd_vm;
    try
    {
        if (posName.empty())
        {
            po::store(po::command_line_parser(argc, argv).options(cmd_line).allow_unregistered().run(), cmd_vm);
        }
        else
        {
            po::positional_options_description p;
            p.add(posName.c_str(), -1);
            po::store(po::command_line_parser(argc, argv).options(cmd_line).allow_unregistered().positional(p).run(), cmd_vm);
        }
        
    }
    catch (std::exception &e)
    {
        std::cerr << "unable to parse expression" << e.what () << std::endl;
        throw (e);
    }

    po::notify (cmd_vm);

    // objects/pointers/variables/constants

    // program options control
    if (cmd_vm.count ("help") > 0)
    {
        std::cout << visible << '\n';
        return helpReturn;
    }
    if (cmd_vm.count("version") > 0)
    {
        return versionReturn;
    }
    if (posName.empty())
    {
        po::store(po::command_line_parser(argc, argv).options(cmd_line).allow_unregistered().run(), vm_map);
    }
    else
    {
        po::positional_options_description p;
        p.add(posName.c_str(), -1);
        po::store(po::command_line_parser(argc, argv).options(cmd_line).allow_unregistered().positional(p).run(), vm_map);
    }
   

    if (cmd_vm.count ("config-file") > 0)
    {
        std::string config_file_name = cmd_vm["config-file"].as<std::string> ();
        if (!boost::filesystem::exists (config_file_name))
        {
            std::cerr << "config file " << config_file_name << " does not exist\n";
            throw (std::invalid_argument ("unknown config file"));
        }
        else
        {
            std::ifstream fstr (config_file_name.c_str ());
            po::store (po::parse_config_file (fstr, config_file), vm_map);
            fstr.close ();
        }
    }

    po::notify (vm_map);
    return 0;
}

}  // namespace utilities
