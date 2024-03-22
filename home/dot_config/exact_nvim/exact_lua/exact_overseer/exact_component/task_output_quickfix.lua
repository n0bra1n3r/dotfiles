return {
  desc = "Write task output to quickfix",
  editable = false,
  serializable = false,
  constructor = function()
    return {
      on_init = function(self)
        self.task_id = nil
      end,
      on_exit = function(self, _, code)
        self.task_id = fn.update_task_output(code, self.task_id)
      end,
      on_output_lines = function(self, _, lines)
        self.task_id = fn.update_task_output(lines, self.task_id)
      end,
      on_start = function(self)
        self.task_id = fn.update_task_output({})
      end,
    }
  end,
}
