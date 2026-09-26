"""Call the user's configured local Aseprite server over MCP stdio."""
import asyncio
import json
import os
from pathlib import Path
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

ROOT = Path(__file__).resolve().parents[2]
SERVER = Path('C:/Users/andre/Repos/aseprite-mcp')

async def main():
    env = dict(os.environ)
    env['ASEPRITE_PATH'] = 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe'
    params = StdioServerParameters(command=str(SERVER / '.venv/Scripts/python.exe'), args=['-m', 'aseprite_mcp'], cwd=str(SERVER), env=env)
    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            available = await session.list_tools()
            names = {tool.name for tool in available.tools}
            print('Connected to Aseprite MCP:', len(names), 'tools')
            async def call(name, args):
                if name not in names:
                    raise RuntimeError('Unavailable MCP tool: ' + name)
                result = await session.call_tool(name, args)
                output = '\n'.join(c.text for c in result.content if hasattr(c, 'text'))
                print(name, output)
                if result.isError or 'Script failed:' in output or output.startswith('Failed'):
                    raise RuntimeError(output)
                return output
            source = str(ROOT / 'art/characters/phuong-v1.aseprite')
            (ROOT / 'public/assets/characters').mkdir(parents=True, exist_ok=True)
            (ROOT / 'art/characters/previews').mkdir(parents=True, exist_ok=True)
            await call('run_lua_script', {'script': (ROOT / 'art/characters/build-phuong.lua').read_text()})
            await call('get_sprite_info', {'filename': source})
            await call('export_spritesheet', {'filename': source, 'output_filename': str(ROOT / 'public/assets/characters/phuong-v1.png'), 'data_filename': str(ROOT / 'public/assets/characters/phuong-v1.json'), 'sheet_type': 'rows', 'data_format':'json-array', 'list_tags':True})
            for direction in ['down','up','left','right']:
                await call('export_tag', {'filename':source,'tag_name':'walk-'+direction,'output_filename':str(ROOT / ('art/characters/previews/phuong-walk-'+direction+'.gif')),'scale':8})
            await call('export_frame', {'filename':source,'frame_index':1,'output_filename':str(ROOT / 'art/characters/previews/phuong-idle.png'),'scale':12})
            await call('export_frame', {'filename':str(ROOT / 'public/assets/characters/phuong-v1.png'),'frame_index':1,'output_filename':str(ROOT / 'art/characters/previews/phuong-sheet.png'),'scale':6})

asyncio.run(main())
