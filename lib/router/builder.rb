class Router
  class Builder
    attr_reader :trie

    def initialize
      @trie = StaticNode.new ''
    end

    def add_route path, params
      raise 'must provide a hash or a string as params' unless params
      process_node @trie, path, params
    end

    def process_node node, path, params
      if path.nil? || path == ''
        case params
        when String
          node.params = {tag: params}
        when Hash
          node.params = params
        end
        return
      end

      head = path[0]
      case head
      when ')'
        process_node node, path[1..-1], params
      when '('
        process_node node, path[1..-1], params
        parentheses = 1
        current_index = 1
        while current_index < path.size
          case path[current_index]
          when '('
            parentheses += 1
          when ')'
            parentheses -= 1
          end

          if parentheses == 0
            process_node node, path[current_index+1..-1], params
            return
          end
          current_index += 1
        end
        raise "missing )"
      when ':'
        current_index = 1
        name = ''
        while current_index < path.size
          case path[current_index]
          when '/', '(', '.', ')'
            break
          else
            name += path[current_index]
            current_index += 1
          end
        end

        if identical = node.children.find{|child| child.dynamic? && child.value == name}
          process_node identical, path[current_index..-1], params
        else
          new_node = node.add_child DynamicNode.new(name)
          process_node new_node, path[current_index..-1], params
        end
      else
        if identical = node.children.find{|child| child.static? && child.value == head}
          process_node identical, path[1..-1], params
        else
          new_node = node.add_child StaticNode.new(head)
          process_node new_node, path[1..-1], params
        end
      end
    end

  end
end
