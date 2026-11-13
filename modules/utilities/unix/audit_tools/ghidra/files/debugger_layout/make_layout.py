#!/usr/bin/env python3
"""Generate a Ghidra 11.1.2 Debugger tool with the dynamic debugging lab's layout.

Usage: make_layout.py STOCK_Debugger.tool OUT.tool

STOCK_Debugger.tool is defaultTools/Debugger.tool from Ghidra/Debug/Debugger/lib/Debugger.jar
in the release under files/release (unzip -p ... defaultTools/Debugger.tool).

Layout (DIVIDER_LOCATION is the first child's share of the split, x1000;
tabs listed in order, the first one showing):

  +----------------+------------------------+-----------------------+
  | Registers      | Listing (static)       | Decompile             |
  | [Breakpoints,  | [Dynamic Listing]      |                       |
  |  Symbol Tree]  |                        |                       |
  +----------------+------------------+-----+-----------------------+
  | Terminal                          | Stack [Memory]              |
  +-----------------------------------+-----------------------------+

Every other pane, including the Debug Console, is kept, closed, as a tab behind Symbol Tree, so the
Window menu can reopen it.  Floating windows are left as they are.
"""
import sys
import xml.etree.ElementTree as ET

SCREEN_W, SCREEN_H = 1470, 828          # the lab VM's display; splits scale with it
CONTENT_H = 700                         # approx. after the menu, toolbar and status bar

# (OWNER, NAME, TITLE or None) of the panes to show
VISIBLE = {
    'registers':   ('DebuggerRegistersPlugin', 'Registers', None),
    'breakpoints': ('DebuggerBreakpointsPlugin', 'Breakpoints', None),
    'stack':       ('DebuggerStackPlugin', 'Stack', None),
    'symbols':     ('SymbolTreePlugin', 'Symbol Tree', None),
    'dynamic':     ('DebuggerListingPlugin', 'Listing', 'Dynamic'),
    'listing':     ('CodeBrowserPlugin', 'Listing', None),
    'decompiler':  ('DecompilePlugin', 'Decompiler', None),
    'memory':      ('DebuggerMemoryBytesPlugin', 'Memory', None),
    'terminal':    ('TerminalPlugin', 'Terminal', None),   # appears when a target is launched
}


MEMORY_STATE = """<PLUGIN_STATE CLASS="ghidra.app.plugin.core.debug.gui.memory.DebuggerMemoryBytesPlugin">
    <XML NAME="connectedProvider">
        <SAVE_STATE>
            <STATE NAME="Bytes Per Line" TYPE="int" VALUE="16" />
            <STATE NAME="Hex view groupsize" TYPE="int" VALUE="1" />
            <STATE NAME="Offset" TYPE="int" VALUE="0" />
            <ARRAY NAME="View Names" TYPE="string">
                <A VALUE="Hex" />
            </ARRAY>
            <SAVE_STATE NAME="View_Widths" TYPE="SaveState">
                <View_Widths>
                    <STATE NAME="Addresses" TYPE="int" VALUE="100" />
                    <STATE NAME="Hex" TYPE="int" VALUE="343" />
                </View_Widths>
            </SAVE_STATE>
            <STATE NAME="autoSpec" TYPE="string" VALUE="1_READ_VIS_RO_ONCE" />
            <STATE NAME="spec" TYPE="string" VALUE="TRACK_PC" />
        </SAVE_STATE>
    </XML>
    <STATE NAME="disconnectedCount" TYPE="int" VALUE="0" />
</PLUGIN_STATE>"""


def indent(el, level=0):
    pad = '\n' + '    ' * level
    if len(el):
        el.text = pad + '    '
        for child in el:
            indent(child, level + 1)
        child.tail = pad
    if level and not (el.tail or '').strip():
        el.tail = el.tail if el.tail and el.tail.strip() == '' and el.tail != pad else pad


def key(ci):
    return (ci.get('OWNER'), ci.get('NAME'), ci.get('TITLE'))


def matches(ci, spec):
    owner, name, title = spec
    return ci.get('OWNER') == owner and ci.get('NAME') == name and (title is None or ci.get('TITLE') == title)


def split(orient, share, w, h, first, second):
    n = ET.Element('SPLIT_NODE', {'WIDTH': str(w), 'HEIGHT': str(h),
                                  'DIVIDER_LOCATION': str(share), 'ORIENTATION': orient})
    n.extend([first, second])
    return n


def stack(infos, top=0):
    n = ET.Element('COMPONENT_NODE', {'TOP_INFO': str(top)})
    n.extend(infos)
    return n


def main(src, dst):
    tree = ET.parse(src)
    root_cfg = tree.getroot()
    tool = root_cfg.find('TOOL')
    rn = root_cfg.find('.//ROOT_NODE')

    main_nodes = [c for c in rn if c.tag != 'WINDOW_NODE']
    windows = [c for c in rn if c.tag == 'WINDOW_NODE']
    assert len(main_nodes) == 1, 'expected one main node'
    infos = [ci for ci in main_nodes[0].iter('COMPONENT_INFO')]

    picked, rest = {}, []
    for ci in infos:
        for name, spec in VISIBLE.items():
            if name not in picked and matches(ci, spec):
                picked[name] = ci
                break
        else:
            rest.append(ci)
    missing = set(VISIBLE) - set(picked)
    assert not missing, f'components not found: {missing}'

    for name, ci in picked.items():
        ci.set('ACTIVE', 'false' if name == 'terminal' else 'true')
    for ci in rest:
        ci.set('ACTIVE', 'false')

    # Proportions taken from a layout arranged by hand in Ghidra on the lab VM
    top_h = int(CONTENT_H * 0.66)
    left_w = int(SCREEN_W * 0.24)
    right_w = SCREEN_W - left_w

    left = stack([picked['registers'], picked['breakpoints'], picked['symbols']] + rest, top=0)
    code = stack([picked['listing'], picked['dynamic']], top=0)
    centre = split('HORIZONTAL', 480, right_w, top_h, code, stack([picked['decompiler']]))
    top_row = split('HORIZONTAL', 240, SCREEN_W, top_h, left, centre)
    bottom_row = split('HORIZONTAL', 560, SCREEN_W, CONTENT_H - top_h,
                       stack([picked['terminal']]), stack([picked['stack'], picked['memory']], top=0))
    new_main = split('VERTICAL', 660, SCREEN_W, CONTENT_H, top_row, bottom_row)

    for c in list(rn):
        rn.remove(c)
    rn.append(new_main)
    rn.extend(windows)
    rn.attrib.update({'X_POS': '0', 'Y_POS': '0', 'WIDTH': str(SCREEN_W), 'HEIGHT': str(SCREEN_H),
                      'EX_STATE': '6', 'FOCUSED_OWNER': 'CodeBrowserPlugin',
                      'FOCUSED_NAME': 'Listing', 'FOCUSED_TITLE': 'Listing: '})

    # Memory tracking is restored from per-project data, not from the tool, so it stays at the default (PC)

    for el in root_cfg.iter():
        el.tail = None
        if len(el):
            el.text = None
    indent(root_cfg)
    tree.write(dst, encoding='UTF-8', xml_declaration=True)
    shown = sorted(n for n in picked if n != 'terminal')
    print(f'wrote {dst}: shown {shown}; terminal placed; {len(rest)} panes closed behind Symbol Tree')


if __name__ == '__main__':
    main(*sys.argv[1:3])
