#!/usr/bin/env ruby
require 'gli'
require 'hacer'

include GLI::App

program_desc 'Visual Studio Solution utilities'

desc 'Open solution in visual studio'
command :open do |c|
  c.action do 
    %x{ source ~/.aliases
      slnopen
    }
  end
end

desc 'Close visual studio instance for solution'
command :close do |c|
  c.action do 
    %x{ source ~/.aliases
      slnclose
    }
  end
end

desc 'Build the solution'
command :build do |c|
  c.action do
    puts %x{ source ~/.aliases
    msbuild /v:m /nologo /p:VisualStudioVersion=12.0
    }
  end
end

desc 'Clean the solution'
command :clean do |c|
  c.action do
    puts %x{ source ~/.aliases
    msbuild /v:m /nologo /t:Clean /p:VisualStudioVersion=12.0
    }
  end
end

desc 'Test the solution'
command :test do |c|
  c.action do |globals, options, args|
    if args.length > 0
      exec("nunit-console /noxml /labels /include:#{args.first} $(cygpath -aw KMDBefordring.nunit)")
    else
      exec("nunit-console /noxml /labels $(cygpath -aw KMDBefordring.nunit)")
    end
  end
end

desc 'Deploy the solution'
command :deploy do |c|
  c.action do |globals, options, args|
    system("/cygdrive/c/Windows/Microsoft.NET/Framework/v4.0.30319/msbuild.exe c:\\\\Users\\\\z8ztm\\\\Source\\\\KMDBefordring\\\\KMDBefordring.sln /p:DeployOnBuild=true /p:PublishProfile=#{args.first} /p:VisualStudioVersion=12.0")
  end
end

exit run(ARGV)
