module HasManyWithSet
  module Queries
    def self.build_find_empty_set_query(set_table_name, set_items_table_name)
      "select #{ set_table_name }.id from #{ set_table_name }
       where not exists (select null from #{ set_items_table_name }
                         where #{ set_items_table_name }.#{ set_table_name.singularize }_id = #{ set_table_name }.id)"
    end

    def self.build_find_set_query(set_table_name, set_items_table_name, child_table_name)
      "select #{ set_table_name }.id from #{ set_items_table_name }
         join #{ set_table_name } on
           #{ set_table_name }.id = #{ set_items_table_name }.#{ set_table_name.singularize }_id
       where
         #{set_items_table_name }.#{ child_table_name.singularize }_id IN (?)
         and (select count(*) from #{ set_items_table_name } c
              where c.#{ set_table_name.singularize }_id =
                    #{ set_items_table_name }.#{ set_table_name.singularize }_id) = ?
       group by #{ set_table_name }.id
       having count(*) = ? "
    end
  end
end
