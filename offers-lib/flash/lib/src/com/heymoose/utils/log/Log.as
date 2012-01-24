/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/28/11
 * Time: 12:20 PM
 */
package com.heymoose.utils.log
{
import flash.events.EventDispatcher;

public class Log extends EventDispatcher
{
	public var sourceArray:Array;

	public function Log ()
	{
		sourceArray = new Array ();
	}
}
}
