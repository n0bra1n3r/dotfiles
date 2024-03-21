return {
  desc = "Write task output to quickfix",
  editable = false,
  serializable = false,
  constructor = function()
    return {
      on_init = function(self)
        self.task_count = 0
        self.qf_name = function()
          return 'task_output_'..self.task_count
        end
      end,
      on_start = function(self)
        self.task_count = self.task_count + 1
        fn.set_qf_items(self.qf_name(), {
          items = {},
        })
      end,
      on_exit = function(self, _, code)
        fn.set_qf_items(self.qf_name(), {
          context = { exit_code = code },
        }, true)
        self.task_count = self.task_count - 1
      end,
      on_output_lines = function(self, _, lines)
        local items = {}
        for _, line in ipairs(lines) do
          table.insert(items, { text = line })
        end
        fn.set_qf_items(self.qf_name(), {
          items = items,
        }, true)
      end,
    }
  end,
}
