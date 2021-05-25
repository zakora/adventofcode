from pathlib import Path
from string import ascii_uppercase
from sys import argv


BASELINE_SEC = 60
N_WORKERS = 5


def parse(filepath):
    def parse_line(line):
        child = line[5]
        parent = line[36]

        # Update parent
        children = tasks.get(parent, [])
        children.append(child)
        tasks[parent] = children

        # Update child
        children = tasks.get(child, [])
        tasks[child] = children

    tasks = {}
    with open(filepath) as ff:
        for line in ff:
            parse_line(line)

    return tasks


def get_next_task(tasks_graph):
    # Find next task
    free = filter(lambda kv: kv[1] == [], tasks.items())
    free = [kv[0] for kv in free]
    free = sorted(free)

    if free:
        return free[0]
    else:
        return None


def pop_task(task, tasks_graph):
    # Remove freed step as a parent in tasks
    tasks_graph.pop(task)

    # Remove freed step as a child in tasks
    for key, val in tasks.items():
        if task in val:
            val.remove(task)

# -- Part A --

def partA(tasks):
    order = []

    while tasks:
        freed = get_next_task(tasks)
        pop_task(freed, tasks)
        order.append(freed)

    return order


# -- Part B --
def collect_free_tasks(state):
    # Move all non-blocking tasks from graph to tasks_free list
    free_tasks = {task for task, deps in state["tasks_graph"].items() if not deps}
    free_tasks -= set([task for (task, _) in state["tasks_inproc"]])
    for task in free_tasks:
        state["tasks_free"].add(task)


def all_done(state):
    return not state["tasks_free"] and not state["tasks_inproc"] and not state["tasks_graph"]


def any_free_task(state):
    return state["tasks_free"]


def any_worker_avail(state):
    return len(state["tasks_inproc"]) < N_WORKERS


def assign_task_worker(state):
    tasks = sorted(state["tasks_free"])
    task = tasks[0]
    wait_sec = compute_wait_sec(task)

    state["tasks_free"].remove(task)
    state["tasks_inproc"].add((task, wait_sec))


def wait_worker(state):
    min_wait_time = min([wait_sec for _, wait_sec in state["tasks_inproc"]])
    state["duration"] += min_wait_time
    state["tasks_inproc"] = {(task, wait_sec - min_wait_time) for task, wait_sec in state["tasks_inproc"]}
    done = {(task, wait_sec) for task, wait_sec in state["tasks_inproc"] if wait_sec == 0}
    state["tasks_inproc"] = state["tasks_inproc"] - done
    state["tasks_done"] += sorted([task for task, _ in done])

    for (task, _) in done:
        pop_task(task, state["tasks_graph"])


def compute_wait_sec(letter):
    costs = {}
    pairs_letter_cost = zip(ascii_uppercase, range(1, len(ascii_uppercase) + 1))
    for ascii_letter, letter_cost in pairs_letter_cost:
        costs[ascii_letter] = BASELINE_SEC + letter_cost

    return costs[letter]


def partB(graph):
    state = {
        "tasks_graph": graph, # holds tasks not done yet
        "tasks_free": set(),
        "tasks_inproc": set(),
        "tasks_done": [],  # list to keep track of order
        "duration": 0
    }
    step = "collect_free_tasks"

    # goto style control flow implemented with while-if-continues
    while step != "end":
        if step == "collect_free_tasks":
            collect_free_tasks(state)
            step = "all_done?"
            continue

        if step == "all_done?":
            if all_done(state):
                step = "end"
            else:
                step = "any_free_task?"
            continue

        if step == "any_free_task?":
            if any_free_task(state):
                step = "any_worker_avail?"
            else:
                step = "wait_worker"
            continue

        if step == "any_worker_avail?":
            if any_worker_avail(state):
                step = "assign_task_worker"
            else:
                step = "wait_worker"
            continue

        if step == "wait_worker":
            wait_worker(state)
            step = "collect_free_tasks"
            continue

        if step == "assign_task_worker":
            assign_task_worker(state)
            step = "any_free_task?"
            continue

    return state["duration"]


if __name__ == '__main__':
    filepath = Path(argv[1])

    # Part A
    tasks = parse(filepath)
    order = partA(tasks)
    print("part A:", "".join(order))

    # Part B
    tasks = parse(filepath)
    print("part B:", partB(tasks))
