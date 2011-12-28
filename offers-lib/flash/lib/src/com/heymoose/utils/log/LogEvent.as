/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/28/11
 * Time: 12:16 PM
 */
package com.heymoose.utils.log
{
import flash.events.Event;

public class LogEvent extends Event
{
	public static const UPDATE_LOG:String = "com.heymoose.utils.log.UPDATE_LOG";
	public function LogEvent ()
	{
		super(UPDATE_LOG, true);
	}
}
}
