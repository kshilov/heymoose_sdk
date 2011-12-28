/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/13/11
 * Time: 3:24 PM
 */
package com.heymoose.core.net
{
import flash.events.Event;

public interface IResponder
{
	function result ( data:Object ):void;

	function fault ( info:Object ):void;

	function log ( token:AsyncToken, event:Event ):void;
}
}
