class ShowOffUtils

  def self.create(dirname,create_samples,dir='one')
    Dir.mkdir(dirname) if !File.exists?(dirname)
    Dir.chdir(dirname) do
      if create_samples
        # create section
        Dir.mkdir(dir)

        # create markdown file
        File.open("#{dir}/01_slide.md", 'w+') do |f|
          f.puts make_slide("My Presentation")
          f.puts make_slide("Bullet Points","bullets incremental",["first point","second point","third point"])
        end
      end

      # create showoff.json
      File.open('showoff.json', 'w+') do |f|
        f.puts '[ {"section":"#{dir}"} ]'
      end

      if create_samples
        puts "done. run 'showoff serve' in #{dirname}/ dir to see slideshow"
      else
        puts "done. add slides, modify showoff.json and then run 'showoff serve' in #{dirname}/ dir to see slideshow"
      end
    end
  end

  def self.heroku(name)
    if !File.exists?('showoff.json')
      puts "fail. not a showoff directory"
      return false
    end
    # create .gems file
    File.open('.gems', 'w+') do |f|
      f.puts "bluecloth"
      f.puts "nokogiri"
      f.puts "showoff"
    end if !File.exists?('.gems')

    # create config.ru file
    File.open('config.ru', 'w+') do |f|
      f.puts 'require "showoff"'
      f.puts 'run ShowOff.new'
    end if !File.exists?('config.ru')

    puts "herokuized. run something like this to launch your heroku presentation:

      heroku create #{name}
      git add .gems config.ru
      git commit -m 'herokuized'
      git push heroku master
    "
  end

  def self.make_slide(title,classes="",content=nil)
    slide = "!SLIDE #{classes}\n"
    slide << "# #{title} #\n"
    slide << "\n"
    if content
      if content.kind_of? Array
        content.each { |x| slide << "* #{x.to_s}\n" }
      else
        slide << content.to_s
      end
    end
    slide
  end


  def self.add_slide(options)
    raise "No such dir #{options[:dir]}" if !File.exists?(options[:dir])
    title = determine_title(options[:title],options[:name],options[:code])
    filename = determine_filename(options[:dir],options[:name],options[:number])
    write_file(filename,options[:code],title)
  end

  def self.write_file(filename,code,title)
    File.open(filename,'w') do |file|
      size = ""
      source = ""
      if code
        source,lines,width = read_code(code)
        size = adjust_size(lines,width)
      end
      file.puts make_slide(title,size,source)
    end
    puts "Wrote #{filename}"
  end

  def self.determine_filename(slide_dir,slide_name,number)
    filename = "#{slide_dir}/#{slide_name}.md"
    if number
      max = 0
      Dir.open(slide_dir).each do |file|
        if file =~ /(\d+).*\.md/
          num = $1.to_i
          max = num if num > max
        end
      end
      max += 1
      max = "0#{max}" if max < 10
      filename = "#{slide_dir}/#{max}_#{slide_name}.md"
    end
    filename
  end

  def self.determine_title(title,slide_name,code)
    if title.nil? || title.strip.length == 0
      title = slide_name 
      title = File.basename(code) if code
    end
    title
  end

  def self.adjust_size(lines,width)
    size = ""
    # These values determined empircally
    size = "small" if width > 50
    size = "small" if lines > 15
    size = "smaller" if width > 57
    size = "smaller" if lines > 19
    puts "warning, your lines are too long and the code may be cut off" if width > 65 
    puts "warning, your code is too long and the code may be cut off" if lines > 23
    size
  end

  def self.read_code(source_file)
    code = "    @@@ #{lang(source_file)}\n"
    lines = 0
    width = 0
    File.open(source_file) do |code_file|
      code_file.readlines.each do |line| 
        code += "    #{line}"
        lines += 1
        width = line.length if line.length > width
      end
    end
    [code,lines,width]
  end

  EXTENSIONS =  { 
    'pl' => 'perl',
    'rb' => 'ruby',
    'erl' => 'erlang'
  }

  def self.lang(source_file)
    ext = File.extname(source_file).gsub(/^\./,'')
    EXTENSIONS[ext] || ext
  end
end
