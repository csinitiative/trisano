module LibrarySpecHelper

  class LibraryTree
    class << self
      def create_question(options={}, &block)
        lib_tree = new
        lib_tree.library_question(options, &block)
        lib_tree
      end

      def create_group(options={}, &block)
        lib_tree = new
        lib_tree.library_group(options, &block)
        lib_tree
      end
    end

    def initialize
      @tree_id = FormElement.next_tree_id
      @nodes = []
    end

    def tree_id
      @tree_id
    end

    def last
      @nodes.last
    end

    def first
      @nodes.first
    end

    def library_question(options = {}, &block)
      options.symbolize_keys!
      options[:tree_id] ||= @tree_id
      options[:is_template] ||= true
      question = Factory.build(:question_element, options)
      question.save!
      last.add_child(question) if last
      @nodes.push(question)
      instance_eval(&block) if block_given?
    end

    def library_follow_up(options={}, &block)
      options.symbolize_keys!
      options[:tree_id] ||= @tree_id
      options[:is_template] ||= true
      follow_up = Factory.build(:follow_up_element, options)
      follow_up.save!
      last.add_child(follow_up)
      @nodes.push(follow_up)
      instance_eval(&block) if block_given?
    end

    def library_group(options={}, &block)
      options.symbolize_keys!
      options[:tree_id] ||= @tree_id
      options[:is_template] ||= true
      group = Factory.build(:group_element, options)
      group.save!
      @nodes.push(group)
      instance_eval(&block) if block_given?
    end

  end

  def library_question(options = {}, &block)
    LibraryTree.create_question options, &block
  end

  def library_group(options = {}, &block)
    LibraryTree.create_group options, &block
  end

end
