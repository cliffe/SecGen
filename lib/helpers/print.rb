class Print
  private
  def self.colorize(text, color_code)
    "#{color_code}#{text}\e[0m"
  end

  public
  def self.red(text); colorize(text, "\e[31m"); end
  def self.green(text); colorize(text, "\e[32m"); end
  def self.yellow(text); colorize(text, "\e[33m"); end
  def self.grey(text); colorize(text, "\e[37m"); end
  def self.bold(text); colorize(text, "\e[2m"); end

  def self.debug(msg)
    puts grey(' ' + msg)
  end

  def self.verbose(msg)
    puts grey(' ' + msg)
  end

  def self.err(msg)
    $stderr.puts red(msg)
  end

  def self.info(msg)
    puts green(msg)
  end

  def self.std(msg)
    puts yellow(msg)
  end
end
