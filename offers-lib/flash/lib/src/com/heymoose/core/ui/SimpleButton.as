/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/13/11
 * Time: 9:38 AM
 */
package com.heymoose.core.ui
{
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

public class SimpleButton extends EventDispatcher
{
	public var skin:Sprite;

	public function SimpleButton ( sprite:Sprite )
	{
		skin = sprite;
		skin.buttonMode = true;
		skin.useHandCursor = true;
		skin.addEventListener ( MouseEvent.CLICK, transferMouseEvent );
	}

	private function transferMouseEvent ( event:MouseEvent ):void
	{
		dispatchEvent ( event );
	}
}
}
